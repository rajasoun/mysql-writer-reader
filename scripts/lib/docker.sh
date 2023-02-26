#!/usr/bin/env bash 

COMPOSE_FILE="${GIT_BASE_PATH}/docker-compose.yaml"

# Start Standalone MySQL database write via Docker
function start_mysql_writer() {
    info "Starting MySQL Writer in standalone mode"
    docker-compose -f $COMPOSE_FILE build
    docker-compose -f $COMPOSE_FILE up mysql_writer adminer -d
    wait_for_mysql "mysql_writer"
    warn "\nMySQL is up and running\n"
    info "Visit http://localhost:8080 to access Adminer\n"
}

# Start Writer Reader MySQL database with replication via Docker
function start_mysql_writer_reader() {
    info "Starting MySQL Writer and Reader in replication mode"
    docker-compose -f $COMPOSE_FILE build
    docker-compose -f $COMPOSE_FILE up -d
    wait_for_mysql "mysql_writer"
    wait_for_mysql "mysql_reader"
    warn "\nMySQL is up and running\n"
    # prepare_mysql_writer_for_replication
    # prepare_mysql_reader_for_replication
    # show_reader_replication_status
    info "Visit http://localhost:8080 to access Adminer\n"
}

# Start MySQL database via Docker
function start_mysql() {
    local replication_flag="$1"
    local replication_choice=$( tr '[:upper:]' '[:lower:]' <<<"$replication_flag" )
    case $replication_choice in
        standalone)start_mysql_writer;;
        *) start_mysql_writer_reader;;
    esac
}

# Stop MySQL database via Docker
function stop_mysql() {
    docker-compose -f $COMPOSE_FILE down -v
    clean_writer_reader_data
}

# List running containers
function ps() {
    docker-compose -f $COMPOSE_FILE ps
}


# Show Logs
function logs() {
    docker-compose -f $COMPOSE_FILE logs -f
}

# Remove data from MySQL database
function clean_writer_reader_data() {
    rm -rf "${PWD}/writer/data"
    rm -rf "${PWD}/reader/data"
}

# Check if MySQL Running in Replication Mode
# Check if MySQL Writer and Reader are running and replication is working fine
function is_mysql_running_in_replication_mode() {
    local mysql_writer_container="mysql_writer"
    local mysql_reader_container="mysql_reader"
    local mysql_writer_status=$(docker inspect -f '{{.State.Running}}' "$mysql_writer_container")
    local mysql_reader_status=$(docker inspect -f '{{.State.Running}}' "$mysql_reader_container")
    if [[ "$mysql_writer_status" == "true" && "$mysql_reader_status" == "true" ]]; then
        return 0
    else
        return 1
    fi
}