#!/usr/bin/env bash

set -eo pipefail

if [ "$DEBUG" = "1" ]; then
    set -x
fi

usage() {
    echo
    echo "Update version number"
    echo
    echo "Usage: $0 [new version number]"
    exit 1
}

matches_version_pattern() {
    local subject=$1
    if [[ "${subject}" =~ ^[v]*[0-9]+\.[0-9]+ ]]; then
        return 0
    fi
    return 1
}

NEW_VERSION=$1


if [ -z "${NEW_VERSION}" ]; then
    echo "missing positional arguments"
    usage
fi

if ! matches_version_pattern "${NEW_VERSION}" ; then
    echo "NEW_VERSION must be a semantic version, got ${NEW_VERSION}"
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
    find ./examples -name \*.tf -print0 | xargs -0 -I '{}' sed -E -i '' "s/ref=v([0-9\.]+)\"/ref=${NEW_VERSION}\"/" "{}"
else
    find ./examples -name \*.tf -print0 | xargs --null -I '{}' sed -E -i "s/ref=v([0-9\.]+)\"/ref=${NEW_VERSION}\"/" "{}"
fi

