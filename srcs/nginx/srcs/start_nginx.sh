#! /bin/sh
(telegraf conf &) & /usr/sbin/sshd && nginx -g 'daemon off;'