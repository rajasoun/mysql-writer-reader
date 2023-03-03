#/usr/bin/env bash 

function print_table() {
    # sql select query result
    result="$1"
    # column names
    echo "$result" | column -t | sed 's/^/\t/'
}
