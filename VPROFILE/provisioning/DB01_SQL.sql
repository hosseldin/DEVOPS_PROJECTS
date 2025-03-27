-- This will be the SQL code that will be included in the VM 

CREATE DATABASE IF NOT EXISTS accounts;
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES on accounts.* TO 'admin'@'%';
FLUSH PRIVILEGES;