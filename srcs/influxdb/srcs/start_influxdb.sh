#!/bin/sh

(telegraf conf &) && influxd run -config /etc/influxdb.conf