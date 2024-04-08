#!/usr/bin/env bash

set -eo pipefail

if [ "$DEBUG" = "1" ]; then
    set -x
fi

usage() {
    echo
    echo "Update docker image tag"
    echo
    echo "Usage: $0 [new tag]"
    exit 1
}

NEW_TAG=$1

if [ -z "${NEW_TAG}" ]; then
    echo "missing positional arguments"
    usage
fi

shift 1
while getopts "" opt; do
    case $opt in
        *)
            usage
            ;;
    esac
done

# Replace text. Unfortunately need to check system since Mac sed is different
if [ "$(uname -s)" = "Darwin" ]; then
    find ./examples -name \*.tf -print0 | xargs -0 -I '{}' sed -E -i '' "s/image_tag = \"[0-9\.]+\"/image_tag = \"${NEW_TAG}\"/" "{}"
else
    find ./examples -name \*.tf -print0 | xargs --null -I '{}' sed -E -i "s/image_tag = \"[0-9\.]+\"/image_tag = \"${NEW_TAG}\"/" "{}"
fi


