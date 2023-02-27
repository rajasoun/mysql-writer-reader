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



