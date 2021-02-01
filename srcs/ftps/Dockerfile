FROM alpine:3.12
MAINTAINER Fabien Buthod-Garcon

RUN apk add vsftpd openrc openssl

COPY srcs/start_ftp.sh /bin/start_ftp.sh
COPY srcs/vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN rc-update add vsftpd default

EXPOSE 21

ENTRYPOINT ["/bin/start_ftp.sh"]