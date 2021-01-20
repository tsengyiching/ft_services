#!/bin/sh

# Install MariaDB database
mariadb-install-db -u root

# start MySQL server
mysqld -u root