#!/usr/bin/env bash 

# Exit if mysql_writer is not running using docker-compose ps 
function exit_if_mysql_writer_not_running() {
    if ! docker-compose -f $COMPOSE_FILE ps | grep -q mysql_writer; then
        error "MySQL Writer is not running. Please start MySQL Writer first."
        exit 1
    fi
}

# Connect to MySQL database via Docker and execute script
function stat() {
    exit_if_mysql_writer_not_running
    local stat_sql_script="${GIT_BASE_PATH}/sql/stat.sql"
    # grep for Max_used_connections to get the max connections used
    local max_writer_used_connections=$(docker exec -i "mysql_writer" mysql --defaults-extra-file=/etc/mysql.client.cnf  < "$stat_sql_script" | grep Max_used_connections | awk '{print $2}')
    warn "MySQL Connection Statistics"
    info "\tWriter Max Used Connections: $max_writer_used_connections"

    if is_mysql_running_in_replication_mode; then 
        local max_reader_used_connections=$(docker exec -i "mysql_reader" mysql --defaults-extra-file=/etc/mysql.client.cnf  < "$stat_sql_script" | grep Max_used_connections | awk '{print $2}')
        info "\tReader Max Used Connections: $max_reader_used_connections"
        # grep for Seconds_Behind_Master to get the replication lag
        local replication_status=$(docker exec mysql_reader sh -c "export MYSQL_PWD=root_password; mysql -u root -e 'SHOW SLAVE STATUS \G'")
        local replication_lag=$(echo "$replication_status" | awk '/Seconds_Behind_Master:/ {print $2}')
        info             "\tReplication Lag: $replication_lag"
    fi
}