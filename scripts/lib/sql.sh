#!/usr/bin/env bash 

# Connect to MySQL database via Docker and execute script
function prepare_for_read_write_ratio() {
    exit_if_container_not_running "mysql_writer"
    local rw_ratio_sql_script="${GIT_BASE_PATH}/sql/read_write_ratio.sql"
    # Setup the database for read write ratio calculation using triggers
    cat $rw_ratio_sql_script | envsubst | docker exec -i mysql_writer sh -c 'export MYSQL_PWD=root_password; mysql -u root'
}

# Execute SQL script on MySQL database via Docker
function execute_sql() {
    local mysql_container="$1"
    local sql_script_path="$2"
    exit_if_container_not_running "$mysql_container"
    # Execute the SQL script with environment variables substitution using envsubst
    cat $sql_script_path | envsubst | docker exec -i $mysql_container sh -c 'export MYSQL_PWD=root_password; mysql -u root'
}