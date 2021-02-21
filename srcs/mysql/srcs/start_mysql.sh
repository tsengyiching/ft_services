#! /bin/sh

# Install MariaDB database
mariadb-install-db -u root
# Start MySQL server
mysqld -u root & sleep 5
# Create database
mysql -u root --execute="CREATE DATABASE wordpress;"
# Create PhpMyAdmin user "user", password "user"
mysql -u root --execute="CREATE USER 'user'@'%' IDENTIFIED BY 'user'; GRANT ALL PRIVILEGES ON *.* TO 'user'@'%' WITH GRANT OPTION; USE wordpress; FLUSH PRIVILEGES;"
# Keep container running
(telegraf conf &) & /usr/bin/mysqld --user=root --datadir=/var/lib/mysql