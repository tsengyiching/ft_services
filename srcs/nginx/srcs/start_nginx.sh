#! /bin/sh
(telegraf conf &) & nginx -g 'daemon off;'