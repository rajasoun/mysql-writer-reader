-- Create replication user on writer that exist allowed to connect from reader host    
CREATE USER "replication_user"@"%" IDENTIFIED BY "replication_password"; 
GRANT REPLICATION SLAVE ON *.* TO "replication_user"@"%"; 
FLUSH PRIVILEGES;