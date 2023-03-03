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

# Delete all rows from table
function delete_all_rows() {
    local container_name="$1"
    local database="$2"
    local table="$3"
    docker exec -i "$container_name" mysql --defaults-extra-file=/etc/mysql.client.cnf "$database" -e "DELETE FROM $table"
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

# Test Reads in both MySQL Writer and MySQL Reader
function test_reads() {
    local writer_container="mysql_writer"
    local reader_container="mysql_reader"
    local database="gorm_spike"
    exit_if_container_not_running "mysql_writer"
    if is_mysql_running_in_replication_mode; then 
        info "MySQL is running in replication mode."
        warn "MySQL Writer"
        output=$(exec_sql_script "$writer_container" "$database" "$GIT_BASE_PATH/sql/test/read_rows.sql")
        print_table "$output"
        warn "MySQL Reader"
        output=$(exec_sql_script "$reader_container" "$database" "$GIT_BASE_PATH/sql/test/read_rows.sql")
        print_table "$output"
    else 
        info "MySQL is running in standalone mode."
        warn "MySQL Writer"
        output=$(exec_sql_script "$writer_container" "$database" "$GIT_BASE_PATH/sql/test/read_rows.sql")
        print_table "$output"
    fi
}

# Delete all rows from table replication_test_logs in database gorm_spike
function delete_all_rows_from_replication_test_logs() {
    local writer_container="mysql_writer"
    local database="gorm_spike"
    local table="replication_test_logs"
    delete_all_rows "$writer_container" "$database" "$table"
    info "Deleted all rows from table $table in database $database"
}

