#!/usr/bin/env bash 

# Execute SQL script on MySQL Container     
# Arguments:
#   $1: Container Name
#   $2: SQL Script Path
#   $3: Database Name
function exec_sql_script() {
    local container_name="$1"
    local database="$2"
    local sql_script_path="$3"
    docker exec -i "$container_name" mysql --defaults-extra-file=/etc/mysql.client.cnf "$database" < "$sql_script_path"
}

# Test Mysql Writer
function test_mysql_writer() {
    local writer_container="mysql_writer"
    local database="gorm_spike"
    exec_sql_script "$writer_container" "$database" "$GIT_BASE_PATH/sql/test/create_table.sql" 
    exec_sql_script "$writer_container" "$database" "$GIT_BASE_PATH/sql/test/insert_row.sql"
    exec_sql_script "$writer_container" "$database" "$GIT_BASE_PATH/sql/test/read_rows.sql"
}

# Test <ysql Reader
function test_mysql_reader() {
    local reader_container="mysql_reader"
    local database="gorm_spike"
    exec_sql_script "$reader_container" "$database" "$GIT_BASE_PATH/sql/test/read_rows.sql"
}

# Test MySQL Replication
function test_replication() {
    exit_if_container_not_running "mysql_writer"
    if is_mysql_running_in_replication_mode; then 
        info "MySQL is running in replication mode."
        test_mysql_writer
        show_reader_replication_status
        test_mysql_reader  
    else 
        info "MySQL is running in standalone mode."
        test_mysql_writer
    fi
}