#!/usr/bin/env bash

GIT_BASE_PATH=$(git rev-parse --show-toplevel)
source "$GIT_BASE_PATH/iaac/scripts/main.sh"

main $@
