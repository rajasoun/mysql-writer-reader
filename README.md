# MySQL Replication Overview 

Provides an overview of MySQL replication and instructions for setting up replication between MySQL clusters.

## What is MySQL Replication?

MySQL replication is a process that copies data from a database server (known as the writer or source) to one or more other servers (called readers or replicas) using binary logs. Replication can be configured to copy either the entire database or specific tables.

By default, replication is asynchronous and one-way, but other synchronization types, such as semi-synchronous and synchronous, may be available through plugins or special configurations.

There are two types of replication setups: chained and circular.

* **Chained replication** involves a chain of database servers where a writer database is replicated to a reader database, which then serves as a source to another reader database and so on.
* **Circular replication** involves changes made on any node of a cluster being replicated to all other nodes in the cluster, creating a circular flow of data throughout the cluster.

## MySQL Replication Topologies

MySQL replication topologies describe the way data is replicated between servers. There are two primary replication topologies: standalone and replication.

### Standalone Mode

Standalone mode refers to a single database server that runs independently of other servers. In standalone mode, the database server acts as both the writer and reader.

To run MySQL in standalone mode, use the following command:

  ```sh
  ./assist.sh up standalone
  ```

### Replication Mode

Replication mode refers to a setup where changes made on a writer database server are replicated to one or more reader databases. In replication mode, the database server acts as the writer or source, and one or more other servers act as readers or replicas.

To run MySQL in replication mode, use the following command:

  ```sh
  ./assist.sh up
  ```

## Setting up MySQL Replication - Manually

To set up MySQL replication, 

1. Create a replication user and grant it replication slave privileges on the writer database server:
    ```sh
    docker exec -it mysql_writer mysql -uroot -proot_password \
    -e "CREATE USER 'replication_user'@'%' IDENTIFIED BY 'replication_user_password';" \
    -e "GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';" \
    -e "SHOW MASTER STATUS;"
    ```
2. Retrieve the current master status of the writer database server:
    ```sh
    MYSQL_WRITER_STATUS=$(docker exec mysql_writer sh -c 'export MYSQL_PWD=root_password; mysql -u root -e "SHOW MASTER STATUS\G"')
    CURRENT_LOG=$(echo "$MYSQL_WRITER_STATUS" | awk '/File:/ {print $2}')
    CURRENT_POS=$(echo "$MYSQL_WRITER_STATUS" | awk '/Position:/ {print $2}')
    ```
3. Configure the reader database server to replicate changes from the writer database server:
    ```sh
    docker exec -it mysql_reader mysql -uroot -proot_password \
        -e "CHANGE MASTER TO MASTER_HOST='mysql_writer', MASTER_USER='replication_user', \
            MASTER_PASSWORD='replication_user_password', MASTER_LOG_FILE='$CURRENT_LOG', MASTER_LOG_POS=$CURRENT_POS;"

    docker exec -it mysql_reader mysql -uroot -proot_password -e "START SLAVE;"
    ```



## AWS Global Aurora MySQL Replication

Amazon Aurora Global Database allows you to set up replication between multiple Aurora clusters in different regions. 
You can set up replication in a circular or chained manner depending on your requirements. 
However, note that once you have set up replication in a certain way, you cannot change the replication topology. 
Therefore, it is important to choose the right replication topology for your needs before setting up replication.

Amazon Aurora Global Database allows you to set up replication between multiple Aurora clusters in different regions. This can be done in either a chained or circular manner, depending on your needs. It is important to choose the right replication topology for your needs before setting up replication because once replication is set up, the topology cannot be changed.

