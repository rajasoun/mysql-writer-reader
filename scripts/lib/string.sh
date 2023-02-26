#!/usr/bin/env bash 

# Function to check whether a string contains a substring
function contains_string {
    string="$1"
    substring="$2"
    if [[ "$string" == *"$substring"* ]]; then
        return 0
    else
        return 1
    fi
}

