#!/bin/sh

adduser -D "root"
echo "root:root1234" | chpasswd

chown -R root:root /var/influxdb
exec su-exec influxdb /var/influxdb/influxd

influx << EOF
CREATE DATABASE $INFLUXDB_NAME;
CREATE USER "$INFLUXDB_USER" WITH PASSWORD '$PASSWORD' WITH ALL PRIVILEGES;
GRANT ALL ON $INFLUXDB_NAME TO $INFLUXDB_USER;
EOF