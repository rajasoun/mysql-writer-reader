-- Generates a trigger for each table in each user database
-- Excludes system databases like mysql, information_schema, and performance_schema, and 
-- logs each database operation to the operations table in the db_operation_logs database.

-- The script creates a stored procedure called "generate_triggers" that loops through all 
-- non-system databases and tables in the server and generates a trigger for each table that logs the 
-- operation to the operations table in the db_operation_logs database.

-- The operations table has columns for the ID of the operation log entry, 
-- the name of the database where the operation occurred, the name of the table where the operation occurred, 
-- a flag indicating whether the operation was a read operation, a flag indicating whether the operation was a write operation, 
-- and a timestamp of when the operation occurred.

-- Create a new database to store the operation logs
CREATE DATABASE IF NOT EXISTS db_operation_logs;

-- Switch to the new database
USE db_operation_logs;

-- Create a table to store the operation logs
CREATE TABLE IF NOT EXISTS operations (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    db_name VARCHAR(255) NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    is_read BOOLEAN NOT NULL,
    is_write BOOLEAN NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Switch back to the original database
USE gorm_spike;

-- Create a stored procedure to generate the trigger for each table in each user database
DELIMITER //

CREATE PROCEDURE generate_triggers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE db_name VARCHAR(255);
    DECLARE table_name VARCHAR(255);

    -- Define cursor to select tables from non-system databases
    DECLARE cur CURSOR FOR
        SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA NOT IN ('mysql', 'information_schema', 'performance_schema');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open cursor
    OPEN cur;

    -- Loop through each table in each user database
    read_loop: LOOP
        FETCH cur INTO db_name, table_name;

        -- Exit loop when done
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Generate a trigger for the current table in the current database
        SET @stmt = CONCAT('CREATE TRIGGER log_', db_name, '_', table_name, '_operations AFTER INSERT ON ', db_name, '.', table_name, ' FOR EACH ROW BEGIN INSERT INTO db_operation_logs.operations (db_name, table_name, is_read, is_write) VALUES (\'', db_name, '\', \'', table_name, '\', NEW.is_read, NEW.is_write); END');

        -- Prepare and execute the statement
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END LOOP;

    -- Close cursor
    CLOSE cur;
END //

-- Call the stored procedure to generate the triggers for all tables in all user databases
CALL generate_triggers();

-- Note: the script assumes that the user running it has the necessary permissions to create triggers
-- and access the INFORMATION_SCHEMA.TABLES table.
