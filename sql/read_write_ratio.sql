-- Configure the Performance Schema to monitor table I/O activity
UPDATE performance_schema.setup_instruments SET ENABLED = 'YES', TIMED = 'YES' WHERE NAME LIKE '%wait/io/table/%';

-- Calculate the read/write ratio for each table
SELECT OBJECT_SCHEMA AS database_name, OBJECT_NAME AS table_name, COUNT_READ, COUNT_WRITE, FORMAT(COUNT_READ / COUNT_WRITE, 2) AS read_write_ratio
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA NOT IN ('performance_schema', 'information_schema') AND COUNT_READ > 0 AND COUNT_WRITE > 0
ORDER BY read_write_ratio DESC;
