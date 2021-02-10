#!/bin/sh
(telegraf conf &) &
cd /var/grafana/bin
./grafana-server --config=/etc/grafana.ini