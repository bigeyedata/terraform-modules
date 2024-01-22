#!/bin/bash
# Description: Generate ca and public/private key pair for use in mTLS
set -e

function usage {
  echo
  echo "Usage: $0 -a <address> -s <stack_name> [-c <company>] [-u <asm_prefix>]"
  echo
  echo "-a <address> - Temporal service address. Example: bigeye-workflows.example.com.  This is the temporal_dns_name output from the Bigeye terraform module"
  echo "-c <company> - This is used in the dn field when generating SSL certs and is optional.  default=Bigeye"
  echo "-s <stack_name> - This is the stack_name output from the Bigeye terraform module and is used for tagging the AWS secrets manager secret with stack=<stack_name>.  This grants access to the secret for the Bigeye ECS cluster."
  echo "-u <asm_prefix> - Use -u to also upload the generated certs to AWS Secrets manager.  The prefix will be used as the first part of the secret name for the files"
  echo "    example: if asm_prefix = /bigeye/mtls, then the files will be uploaded as /bigeye/mtls/{mtls_ca_pem, mtls_pem, mtls_key, mtls_client_ca_bundle_tgz}"
  echo
  echo "There will be 4 files that are generated that will be used by the Bigeye stack"
  echo "${CERTS_DIR}/${CERT_FILE_PREFIX}_ca.pem - ca public cert.  Will be imported as SECRETS_TEMPORAL_PUBLIC_MTLS_CA_BASE64"
  echo "${CERTS_DIR}/${CERT_FILE_PREFIX}.pem - public cert.  Will be imported as SECRETS_TEMPORAL_PUBLIC_MTLS_BASE64"
  echo "${CERTS_DIR}/${CERT_FILE_PREFIX}.key - private key.  Will be imported as SECRETS_TEMPORAL_PRIVATE_MTLS_BASE64"
  echo "${CERTS_DIR}/${CERT_FILE_PREFIX}_client_ca_bundle.tgz - tar ball of ca's that Temporal will trust certs for.  Will be imported as SECRETS_TEMPORAL_MTLS_CA_BUNDLE_BASE64"
  echo
  exit 1
}

function set_defaults {
  export CERT_FILE_PREFIX=mtls
  export COMPANY=Bigeye
  export CERTS_DIR="./mtls_certs"
}

function print_log {
  echo ">>> ${1}"
}

function print_warning {
  echo ">>> ****"
  echo ">>> **** ${1}"
  echo ">>> ****"
}

function generate_server_ca() {
  local company temporal_address certs_dir conf_file
  company="$1"
  temporal_address="$2"
  certs_dir="$3"
  conf_file="${certs_dir}/ca.conf"

  print_log "Generate a private key and a certificate for a certificate authority"

  cat >"$conf_file" << EOF
[req]
default_bits = 4096
default_md = sha256
req_extensions = req_ext
x509_extensions = v3_ca
distinguished_name = dn
prompt = no
[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical,CA:TRUE,pathlen:0
keyUsage = critical,digitalSignature,cRLSign,keyCertSign
[req_ext]
subjectAltName = @alt_names
[dn]
O = $company
[alt_names]
DNS.1 = $temporal_address
EOF

  openssl genrsa -out "${certs_dir}/${CERT_FILE_PREFIX}_ca.key" 4096
  openssl req -new -x509 -days 365 -key "${certs_dir}/${CERT_FILE_PREFIX}_ca.key" -out "${certs_dir}/${CERT_FILE_PREFIX}_ca.pem" -config "$conf_file"

  rm "$conf_file"
  echo Done.
}

function generate_server_certs() {
  local company temporal_address certs_dir conf_file
  company="$1"
  temporal_address="$2"
  certs_dir="$3"
  conf_file="${certs_dir}/client_certs.conf"

  print_log "Generating client key pair"
  cat <<-EOF >"${conf_file}"
[req]
default_bits = 4096
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
prompt = no
[req_ext]
subjectAltName = @alt_names
[dn]
C = US
ST = CA
O = $company
[alt_names]
DNS.1 = $temporal_address
EOF

  # Generate client's private key and certificate signing request (CSR)
  openssl req -newkey rsa:4096 -nodes -keyout "${certs_dir}/${CERT_FILE_PREFIX}.key" -out "${certs_dir}/${CERT_FILE_PREFIX}.csr" -config "$conf_file"
  # Use CA's private key to sign client's CSR and get back the signed certificate
  openssl x509 -days 365 -req -in "${certs_dir}/${CERT_FILE_PREFIX}.csr" -CA "${certs_dir}/${CERT_FILE_PREFIX}_ca.pem" -CAkey "${certs_dir}/${CERT_FILE_PREFIX}_ca.key" -CAcreateserial -out "${certs_dir}/${CERT_FILE_PREFIX}.pem" -extfile "$conf_file" -extensions req_ext
  # Delete the certificate signing request after the certificate has been signed.
  rm "${certs_dir}/${CERT_FILE_PREFIX}.csr"

  rm "$conf_file"
  echo "Done."
}

function generate_trust_bundle() {
  local certs_dir ca_file
  certs_dir="$1"
  ca_file="${CERT_FILE_PREFIX}_ca.pem"

  print_log
  tar -r -C "${certs_dir}" -f "${certs_dir}/${CERT_FILE_PREFIX}_client_ca_bundle.tar" "$ca_file"
  gzip "${certs_dir}/${CERT_FILE_PREFIX}_client_ca_bundle.tar"
}

function aws_credentials_valid() {
  aws sts get-caller-identity
}

function upsert_secret_file() {
  local cert_file secret_id tags b64_string stack
  cert_file="$1"
  secret_id="$2"
  stack="$3"
  tags="[{\"Key\": \"stack\", \"Value\": \"$stack\"},{\"Key\": \"app\", \"Value\": \"bigeye\"}]"

  print_log "Uploading $cert_file to AWS secrets manager $secret_id base64 encoded."
  # shellcheck disable=SC2002
  b64_string=$(cat "${cert_file}" | base64)
  # shellcheck disable=SC2086
  aws secretsmanager create-secret --name "${secret_id}" --secret-string "$b64_string" 2>/dev/null ||
    aws secretsmanager put-secret-value --secret-id "${secret_id}" --secret-string "$b64_string"
  aws secretsmanager tag-resource --secret-id "${secret_id}" --tags "$tags"
}

function upload_to_aws_secrets_manager() {
  local certs_dir secret_id_prefix stack
  certs_dir="$1"
  secret_id_prefix="$2"
  stack="$3"

  for fq_file in "${certs_dir}"/*; do
    file=$(basename "$fq_file")
    # secred id is the file name with dots replaced by underscores
    upsert_secret_file "${certs_dir}/${file}" "${secret_id_prefix}/${file//./_}" "$stack"
  done
}

##############
# BEGIN MAIN #
##############
set_defaults
while getopts "ha:c:s:u:" opt; do
  case $opt in
  h)
    usage
    ;;
  a)
    TEMPORAL_ADDRESS="$OPTARG"
    ;;
  c)
    COMPANY="$OPTARG"
    ;;
  s)
    STACK="$OPTARG"
    ;;
  u)
    SECRET_ID_PREFIX="$OPTARG"
    ;;
  *)
    usage
    ;;
  esac
done

if [ -z "$TEMPORAL_ADDRESS" ]; then
  print_warning "-a <temporal address> is a required arg"
  usage
fi
if [ -z "$STACK" ]; then
  print_warning "-s <stack_name> is a required arg"
  usage
fi
if [[ -x "$CERTS_DIR" ]]; then
  echo
  print_warning "Existing cert dir already exists: $CERTS_DIR.  Remove it first and re-run if you wish to continue."
  echo
  exit 1
fi

echo
echo "CERTS_DIR: $CERTS_DIR"
echo "COMPANY: $COMPANY"
echo "SECRET_ID_PREFIX: $SECRET_ID_PREFIX"
echo "STACK: $STACK"
echo "TEMPORAL_ADDRESS: $TEMPORAL_ADDRESS"
echo

mkdir -p "$CERTS_DIR"

generate_server_ca "$COMPANY" "$TEMPORAL_ADDRESS" "$CERTS_DIR"
generate_server_certs "$COMPANY" "$TEMPORAL_ADDRESS" "$CERTS_DIR"
generate_trust_bundle "$CERTS_DIR"

echo
print_log "Output files:"
print_log "${CERTS_DIR}/${CERT_FILE_PREFIX}_ca.key - used to generate certs, Bigeye services will not need this."
print_log "${CERTS_DIR}/${CERT_FILE_PREFIX}_ca.pem - ca public cert.  Will be imported as SECRETS_TEMPORAL_PUBLIC_MTLS_CA_BASE64"
print_log "${CERTS_DIR}/${CERT_FILE_PREFIX}.pem - public cert.  Will be imported as SECRETS_TEMPORAL_PUBLIC_MTLS_BASE64"
print_log "${CERTS_DIR}/${CERT_FILE_PREFIX}.key - private key.  Will be imported as SECRETS_TEMPORAL_PRIVATE_MTLS_BASE64"
print_log "${CERTS_DIR}/${CERT_FILE_PREFIX}_client_ca_bundle.tgz - tar ball of ca's that Temporal will trust certs for.  Will be imported as SECRETS_TEMPORAL_MTLS_CA_BUNDLE_BASE64"
echo

if [[ -z "$SECRET_ID_PREFIX" ]]; then
  print_log "-u was not specified.  Skipping upload to AWS secrets manager."
else
  aws_credentials_valid
  upload_to_aws_secrets_manager "$CERTS_DIR" "$SECRET_ID_PREFIX" "$STACK"
fi

echo
print_log "Success!"
echo

# This can be used to verify the generated certs
# openssl x509 -noout -text -in <cert file>
