#!/usr/bin/env bash 

# Connect to MySQL database via Docker and execute script
function stat() {
    local stat_sql_script="${GIT_BASE_PATH}/sql/stat.sql"
    # grep for Max_used_connections to get the max connections used
    local max_writer_used_connections=$(docker exec -i "mysql_writer" mysql --defaults-extra-file=/etc/mysql.client.cnf  < "$stat_sql_script" | grep Max_used_connections | awk '{print $2}')
    local max_reader_used_connections=$(docker exec -i "mysql_reader" mysql --defaults-extra-file=/etc/mysql.client.cnf  < "$stat_sql_script" | grep Max_used_connections | awk '{print $2}')
   
    warn "MySQL Replication Status"
    info "\tWriter Max Used Connections: $max_writer_used_connections"
    info "\tReader Max Used Connections: $max_reader_used_connections"

    if ! is_standalone_mysql; then 
        # grep for Seconds_Behind_Master to get the replication lag
        local replication_status=$(docker exec mysql_reader sh -c "export MYSQL_PWD=root_password; mysql -u root -e 'SHOW SLAVE STATUS \G'")
        local replication_lag=$(echo "$replication_status" | awk '/Seconds_Behind_Master:/ {print $2}')
        info             "\tReplication Lag: $replication_lag"
    fi
}