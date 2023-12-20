#!/bin/bash
set -e

function usage {
  echo
  echo "Caches Bigeye docker repo in a local ECR registry."
  echo
  echo "Usage: $0  -r <local_registry> -v <version>"
  echo " -r <local_ecr_registry> ie <aws_account_id>.dkr.ecr.<region>.amazonaws.com"
  echo " -v <version> - this is the Bigeye app version to clone.  ie 1.32.0"
  echo
  echo "Pre-reqs:"
  echo " - AWS cli setup"
  echo " - You have access to Bigeye ECR images.  Contact Bigeye support with your aws account id for access."
  echo " - local ECR repos already created in your account (see main.tf for terraform to create the repos)"
  echo " - You know what version you want to cache.  IE run list_bigeye_images.sh first"
  echo " - 10GB of free disk space to temporarily cache the images on the system where this script is being run"
  echo
  exit 1
}

function set_defaults {
  source_registry="021451147547.dkr.ecr.us-west-2.amazonaws.com"
  destination_registry=""
  version=""
  bigeye_repos=("datawatch" "haproxy" "monocle" "scheduler" "temporal" "temporalui" "toretto" "web")
}

function aws_ecr_login {
  local registry
  registry="$1"
  echo "Logging into ECR registry: $registry"
  aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin "$registry"
}

function tag_and_push_image {
  local source_image=$1
  local destination_image=$2

  echo "Tagging and publishing image: ${source_image} -> ${destination_image}"
  if ! docker tag "${source_image}" "${destination_image}" ; then
    echo "ERROR: Re-tagging failed. Exiting..."
    exit 1
  fi

  if ! docker push "${destination_image}" ; then
    echo "ERROR: Docker push failed. Exiting..."
    exit 1
  fi
}

#######
# MAIN
#######
set_defaults

while getopts "hr:v:" opt; do
  case $opt in
  r)
    destination_registry="$OPTARG"
    ;;
  v)
    version="$OPTARG"
    ;;
  h|*)
    usage
    ;;
  esac
done

if [[ -z "$destination_registry" || -z "$version" ]]; then
  echo
  usage
fi

echo "Repo list: ${bigeye_repos[*]}"
echo "version: $version"
echo

aws_ecr_login "$destination_registry"

for repo in "${bigeye_repos[@]}"; do
  image="${repo}:${version}"

  echo "Retagging and pushing ${destination_registry}/${image}"
  tag_and_push_image "${source_registry}/${image}" "${destination_registry}/${image}"
done

echo
echo "=== Success ==="
echo
