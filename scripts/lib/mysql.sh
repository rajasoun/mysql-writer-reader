#!/usr/bin/env bash 

# Wait for MySQL database to be ready
function wait_for_mysql() {
    mysql_container_name="$1"
    # Wait for MySQL to start up 
    until docker exec -i "$mysql_container_name" mysqladmin ping --silent > /dev/null 2>&1
    do
        echo "Waiting for $mysql_container_name database up..."
        sleep 1
    done
    # Wait for MySQL to be ready use mysql.client.cnf
    until docker exec -i "$mysql_container_name" mysql --defaults-extra-file=/etc/mysql.client.cnf -e ";" > /dev/null 2>&1
    do
        echo "Waiting for $mysql_container_name database ready..."
        sleep 1
    done
}

# Prepare MySQL writer for replication
function prepare_mysql_writer_for_replication() {
    # Create reader db replication user in MySQL writer
    #priv_stmt='CREATE USER "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%"; FLUSH PRIVILEGES;'
    priv_stmt='CREATE USER "replication_user"@"%" IDENTIFIED BY "replication_password"; GRANT REPLICATION SLAVE ON *.* TO "replication_user"@"%"; FLUSH PRIVILEGES;'
    docker exec mysql_writer sh -c "export MYSQL_PWD=root_password; mysql -u root -e '$priv_stmt'"
    info "MySQL writer is ready for replication"
}

# Prepare MySQL reader for replication
function prepare_mysql_reader_for_replication() {
    # Get current log and position from MySQL writer
    MYSQL_WRITER_STATUS=$(docker exec mysql_writer sh -c 'export MYSQL_PWD=root_password; mysql -u root -e "SHOW MASTER STATUS"')
    CURRENT_LOG=$(echo "$MYSQL_WRITER_STATUS" | awk '/File:/ {print $2}')
    CURRENT_POS=$(echo "$MYSQL_WRITER_STATUS" | awk '/Position:/ {print $2}')

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



