#!/usr/bin/env bash

set -eo pipefail

if [ "$DEBUG" = "1" ]; then
    set -x
fi

usage() {
    echo
    echo "Replace old version number with new version number"
    echo
    echo "Usage: $0 [old version number] [new version number]"
    exit 1
}

matches_version_pattern() {
    local subject=$1
    if [[ "${subject}" =~ ^[v]*[0-9]+\.[0-9]+ ]]; then
        return 0
    fi
    return 1
}

OLD_VERSION=$1
NEW_VERSION=$2

if [ -z "${OLD_VERSION}" ] || [ -z "${NEW_VERSION}" ]; then
    echo "missing positional arguments"
    usage
fi
if ! matches_version_pattern ${OLD_VERSION} ; then
    echo "OLD_VERSION must be a semantic version, got ${OLD_VERSION}"
    usage
fi

if ! matches_version_pattern ${NEW_VERSION} ; then
    echo "NEW_VERSION must be a semantic version, got ${NEW_VERSION}"
    usage
fi

shift 2
while getopts "" opt; do
    case $opt in
        *)
            usage
            ;;
    esac
done

# Replace text. Unfortunately need to check system since Mac sed is different
if [ "$(uname -s)" = "Darwin" ]; then
    find ./docs -name \*.tf -print0 | xargs -I '{}' sed -i '' "s/${OLD_VERSION}/${NEW_VERSION}/g" "{}"
else
    find ./docs -name \*.tf -print0 | xargs -I '{}' sed -i "s/${OLD_VERSION}/${NEW_VERSION}/g" "{}"
fi

