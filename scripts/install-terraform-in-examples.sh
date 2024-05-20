#!/bin/bash

if [ "$(uname -s)" = "Darwin" ]; then
    find ./examples -maxdepth 1 -type d \( ! -name . \) -print0 | xargs -0 -I '{}' terraform -chdir="{}" init
else
    find ./examples -maxdepth 1 -type d \( ! -name . \) -print0 | xargs --null -I '{}' terraform -chdir="{}" init
fi
