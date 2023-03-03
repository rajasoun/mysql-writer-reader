#!/usr/bin/env bash

# Function : usage
# Description:
#   Prints usage instructions and a list of valid options to the terminal.
function usage() {
    error "Usage: $0 < up | down | ps | stat | test | logs >"
    warn "\tAvailable options"
    info "\t   up:   Start MySQL and create database"
    info "\t down:   Stop MySQL"
    info "\t   ps:   List running containers"
    info "\t stat:   Print database statistics"
    info "\t test:   Test MySQL replication"
    info "\t read:   Test MySQL reads"
    info "\tclean:   Delete all rows from replication test logs"
    info "\t logs:   Show Container logs"
}
