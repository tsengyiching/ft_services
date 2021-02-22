#! /bin/sh

# Install MariaDB database
mysql_install_db --user=mysql --datadir=/var/lib/mysql
mkdir /run/openrc
touch /run/openrc/softlevel
openrc

rc-service mariadb start

# Create database
mysql -u root --execute="CREATE DATABASE wordpress;"
# Create Wordpress user "admin", password "admin"
mysql -u root --execute="CREATE USER 'admin'@'%' IDENTIFIED BY 'admin'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION; USE wordpress; FLUSH PRIVILEGES;"
# Create PhpMyAdmin user "user", password "user"
mysql -u root --execute="CREATE USER 'user'@'%' IDENTIFIED BY 'user'; GRANT ALL PRIVILEGES ON *.* TO 'user'@'%' WITH GRANT OPTION; USE wordpress; FLUSH PRIVILEGES;"

rc-service mariadb restart

pkill mysqld

(telegraf conf &) & /usr/bin/mysqld --user=root --datadir=/var/lib/mysql