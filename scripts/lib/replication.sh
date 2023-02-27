#!/usr/bin/env bash

# Check if User Exists in Mysql Database
function user_exists_in_reader(){
    export sql_user="$1"
    local mysql_container="mysql_reader"
    local sql_script_path="${GIT_BASE_PATH}/sql/replication/select_user.sql"
    if execute_sql "$mysql_container" $sql_script_path | grep -q "$1"; then
        info "\t$mysql_container has $sql_user"
    else
        error "$mysql_container does not have $sql_user. Re Run the ./assist.sh up"
        exit 1
    fi
}

# Check if User Exists in Mysql Database
function user_exists_in_writer(){
    export sql_user="$1"
    local mysql_container="mysql_writer"
    local sql_script_path="${GIT_BASE_PATH}/sql/replication/select_user.sql"
    if execute_sql "$mysql_container" $sql_script_path | grep -q "$1"; then
        info "\t$mysql_container has $sql_user"
    else
        warn "\t$sql_user does not exist in $mysql_container"
        # Create replication_user in mysql_reader
        local sql_script_path="${GIT_BASE_PATH}/sql/replication/create_user.sql"
        execute_sql "mysql_writer" $sql_script_path
        info "\t$sql_user created in $mysql_container"
    fi
}

# Prepare MySQL writer for replication
function prepare_mysql_writer_for_replication() {
    info "-------------------------------------------------------------"
    info "Preparing MySQL writer for replication with replication_user"
    local sql_user="replication_user"
    user_exists_in_reader "$sql_user" 
    user_exists_in_writer "$sql_user"
    info "-------------------------------------------------------------"
    info "MySQL writer is ready for replication"

    # # Create reader db replication user in MySQL writer
    # priv_stmt='CREATE USER "replication_user"@"%" IDENTIFIED BY "replication_password"; GRANT REPLICATION SLAVE ON *.* TO "replication_user"@"%"; FLUSH PRIVILEGES;'
    # docker exec mysql_writer sh -c "export MYSQL_PWD=root_password; mysql -u root -e '$priv_stmt'"
    # info "MySQL writer is ready for replication"
}

# Prepare MySQL reader for replication
function prepare_mysql_reader_for_replication() {
    local writer_status_sql_file=""${GIT_BASE_PATH}/sql/replication/writer_status.sql""
    MYSQL_WRITER_STATUS=$(execute_sql "mysql_writer" $writer_status_sql_file)
    export CURRENT_LOG=$(echo "$MYSQL_WRITER_STATUS" | awk 'NR>1 {print $1}')
    export CURRENT_POS=$(echo "$MYSQL_WRITER_STATUS" | awk 'NR>1 {print $2}')

    # # Get current log and position from MySQL writer
    # MYSQL_WRITER_STATUS=$(docker exec mysql_writer sh -c 'export MYSQL_PWD=root_password; mysql -u root -e "SHOW MASTER STATUS"')
    # CURRENT_LOG=$(echo "$MYSQL_WRITER_STATUS" | awk 'NR>1 {print $1}')
    # CURRENT_POS=$(echo "$MYSQL_WRITER_STATUS" | awk 'NR>1 {print $2}')

    # local start_replication_in_reader_sql_file="${GIT_BASE_PATH}/sql/replication/start_replication_in_reader.sql"
    # export MASTER_HOST="mysql_writer"
    # export MASTER_USER="replication_user"
    # export MASTER_PASSWORD="replication_password"
    # export MASTER_LOG_FILE="$CURRENT_LOG"
    # export MASTER_LOG_POS="$CURRENT_POS"
    # execute_sql "mysql_reader" "$start_replication_in_reader_sql_file"
    # info "MySQL reader is ready for replication"

    #Start replication in MySQL reader
    start_reader_stmt="CHANGE MASTER TO MASTER_HOST='mysql_writer', MASTER_USER='replication_user', MASTER_PASSWORD='replication_password', MASTER_LOG_FILE='$CURRENT_LOG', MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
    start_reader_cmd="export MYSQL_PWD=root_password; mysql -u root -e \"$start_reader_stmt\""
    docker exec mysql_reader sh -c "$start_reader_cmd"
    info "MySQL reader is ready for replication"
}

# Show MySQL Replication Status
function show_reader_replication_status() {
    local replication_status=$(docker exec mysql_reader sh -c "export MYSQL_PWD=root_password; mysql -u root -e 'SHOW SLAVE STATUS \G'")
    # Check if replication is running
    local replication_running=$(echo "$replication_status" | awk '/Slave_IO_Running:/ {print $2}')
    if [ "$replication_running" != "Yes" ]; then
        error "Replication is not running"
        return 1
    else 
        info "Replication is running"
    fi
    # Check if replication lag is zero using Seconds_Behind_Master: 0
    local replication_lag=$(echo "$replication_status" | awk '/Seconds_Behind_Master:/ {print $2}')
    if [ "$replication_lag" != "0" ]; then
        error "Replication lag is not zero"
        return 1
    else 
        info "Replication lag is zero"
    fi
}
