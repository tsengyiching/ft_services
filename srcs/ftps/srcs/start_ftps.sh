#!/bin/sh

adduser -D "admin"
echo "admin:admin" | chpasswd
(telegraf conf &) &
# Create self certificate
openssl req -new -x509 -days 365 -nodes -out /etc/ssl/private/vsftpd.cert.pem -keyout /etc/ssl/private/vsftpd.key.pem -subj "/C=FR/ST=Lyon/L=Lyon/O=42 School/OU=42student/CN=localhost"
chown root:root /etc/ssl/private/vsftpd.cert.*
chmod 600 /etc/ssl/private/vsftpd.cert.*
vsftpd -opasv_min_port=21000 -opasv_max_port=21010 -opasv_address=172.17.0.2 /etc/vsftpd/vsftpd.conf
