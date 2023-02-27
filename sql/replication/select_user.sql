-- Check if replication user exists in mysql.user table
SELECT User FROM mysql.user WHERE User = "$sql_user";
