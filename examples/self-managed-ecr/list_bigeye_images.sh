#!/bin/bash
set -e

function usage {
  echo
  echo "List available Bigeye images.  The latest image will be the last one printed."
  echo
  echo "Usage: $0"
  echo
  echo "Pre-reqs:"
  echo " - AWS cli setup"
  echo " - You have access to Bigeye ECR images.  Contact Bigeye support with your aws account id for access."
  echo " - jq installed (it's a json formatter)"
  echo
  exit 1
}

#######
# MAIN
#######
while getopts "h" opt; do
  case $opt in
  h|*)
    usage
    ;;
  esac
done

aws ecr describe-images \
  --registry-id 021451147547 \
  --repository-name datawatch \
  --region us-west-2 \
  --query 'sort_by(imageDetails,& imagePushedAt)[*]' \
  --output json | jq '.[] | {version: .imageTags|.[0], imagePushedAt}'
