#!/usr/bin/env bash

GIT_BASE_PATH=$(git rev-parse --show-toplevel)
source "$GIT_BASE_PATH/scripts/main.sh"

main $@
