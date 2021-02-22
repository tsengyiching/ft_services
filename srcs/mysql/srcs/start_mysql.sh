#! /bin/sh

# Install MariaDB database
mariadb-install-db -u root
# Start MySQL server
mysqld -u root & sleep 5
# Create database
mysql -u root --execute="CREATE DATABASE wordpress;"
# Create Wordpress user "admin", password "admin"
mysql -u root --execute="CREATE USER 'admin'@'%' IDENTIFIED BY 'admin'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION; USE wordpress; FLUSH PRIVILEGES;"
# Create PhpMyAdmin user "user", password "user"
mysql -u root --execute="CREATE USER 'user'@'%' IDENTIFIED BY 'user'; GRANT ALL PRIVILEGES ON *.* TO 'user'@'%' WITH GRANT OPTION; USE wordpress; FLUSH PRIVILEGES;"
# Keep container running
(telegraf conf &) & sleep infinite