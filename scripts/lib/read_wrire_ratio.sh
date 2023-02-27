#!/usr/bin/env bash 

# Connect to MySQL database via Docker and execute script
function prepare_for_read_write_ratio() {
    exit_if_mysql_writer_not_running
    local rw_ratio_sql_script="${GIT_BASE_PATH}/sql/read_write_ratio.sql"
    # Setup the database for read write ratio calculation using triggers
    cat $rw_ratio_sql_script | envsubst | docker exec -i mysql_writer sh -c 'export MYSQL_PWD=root_password; mysql -u root'
}