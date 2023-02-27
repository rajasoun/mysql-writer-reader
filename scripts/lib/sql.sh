#!/usr/bin/env bash 

# Execute SQL script on MySQL database via Docker
function execute_sql() {
    local mysql_container="$1"
    local sql_script_path="$2"
    exit_if_container_not_running "$mysql_container"
    # Execute the SQL script with environment variables substitution using envsubst
    cat $sql_script_path | envsubst | docker exec -i $mysql_container sh -c 'export MYSQL_PWD=root_password; mysql -u root'
}