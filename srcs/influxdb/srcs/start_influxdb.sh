#!/bin/sh

adduser -D "root"
echo "root:root1234" | chpasswd

chown -R root:root /var/influxdb
(telegraf conf &) & 
exec su-exec influxdb /var/influxdb/influxd
