#!/usr/bin/env bash 


# Start Standalone MySQL database write via Docker
function start_mysql_writer() {
    local compose_file="${GIT_BASE_PATH}/iaac/mysql/docker-compose.yaml"
    docker-compose -f $compose_file build
    docker-compose -f $compose_file up mysql_writer adminer -d
    wait_for_mysql "mysql_writer"
    warn "\nMySQL is up and running\n"
    info "Visit http://localhost:8080 to access Adminer\n"
}

# Start Writer Reader MySQL database with replication via Docker
function start_mysql_writer_reader() {
    local compose_file="${GIT_BASE_PATH}/iaac/mysql/docker-compose.yaml"
    docker-compose -f $compose_file build
    docker-compose -f $compose_file up -d
    wait_for_mysql "mysql_writer"
    wait_for_mysql "mysql_reader"
    warn "\nMySQL is up and running\n"
    prepare_mysql_writer_for_replication
    prepare_mysql_reader_for_replication
    show_reader_replication_status
    info "Visit http://localhost:8080 to access Adminer\n"
}

# Start MySQL database via Docker
function start_mysql() {
    local compose_file="${GIT_BASE_PATH}/iaac/mysql/docker-compose.yaml"
    local replication_flag="$1"
    local replication_choice=$( tr '[:upper:]' '[:lower:]' <<<"$replication_flag" )
    case $replication_choice in
        standalone)start_mysql_writer;;
        *) start_mysql_writer_reader;;
    esac
}

# Stop MySQL database via Docker
function stop_mysql() {
    local compose_file="${GIT_BASE_PATH}/iaac/mysql/docker-compose.yaml"
    docker-compose -f $compose_file down -v
    # check if compose_file contains "writer-reader" and clean data in one line 
    [[ $compose_file == *"writer-reader"* ]] && clean_writer_reader_data
}

# List running containers
function ps() {
    local compose_file="${GIT_BASE_PATH}/iaac/mysql/docker-compose.yaml"
    docker-compose -f $compose_file ps
}

# Remove data from MySQL database
function clean_writer_reader_data() {
    rm -rf "${PWD}/iaac/mysql/writer/data"
    rm -rf "${PWD}/iaac/mysql/reader/data"
}
