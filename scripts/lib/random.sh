#!/usr/bin/env bash 

# Generate a random string of a given length
function generate_random_string() {
    local length=$1
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1
}

# Generate a random username of a given length
function generate_random_username() {
    local length=$1
    generate_random_string "$length"
}

# Generate a random email address of a given length
function generate_random_email() {
    local username_length=$1
    local domain_length=$2
    local username=$(generate_random_string "$username_length")
    local domain=$(generate_random_string "$domain_length").com
    echo "$username@$domain"
}

