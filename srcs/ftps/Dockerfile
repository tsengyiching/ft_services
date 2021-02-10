FROM alpine:3.12

EXPOSE 21

RUN apk add vsftpd openrc openssl

# Install Telegraf
RUN apk add telegraf --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY srcs/start_ftps.sh /bin/start_ftps.sh
COPY srcs/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./srcs/telegraf.conf /etc/telegraf/
RUN chmod +x /bin/start_ftps.sh
RUN rc-update add vsftpd default

ENTRYPOINT ["/bin/start_ftps.sh"]