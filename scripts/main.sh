#!/usr/bin/env bash

GIT_BASE_PATH=$(git rev-parse --show-toplevel)
source "$GIT_BASE_PATH/scripts/lib/loader.sh"

# Function : Main function
# Description : 
#   Accepts an option as a command-line argument. 
#   The option is passed to the script when it is executed, and it is stored in the opt variable and 
#   converts the option to lowercase using the tr command and stores the result in the choice variable.
function main(){
    local opt="$1"
    shift 1
    choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
    case $choice in
        up)start_mysql $@;;
        ps)ps;;
        down)stop_mysql;;
        stat)stat;;
        test)test_replication;;
        *) usage;;
    esac
}

