CREATE TABLE IF NOT EXISTS replication_test_logs (
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    username VARCHAR(255),
    email VARCHAR(255)
);
