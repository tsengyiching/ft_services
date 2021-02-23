FROM alpine:3.12

EXPOSE 8086

RUN apk update --no-cache
RUN apk upgrade --no-cache
RUN apk add openrc --no-cache
RUN apk add influxdb --no-cache
RUN apk add telegraf --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY srcs/telegraf.conf /etc/telegraf/
COPY srcs/start_influxdb.sh /start_influxdb.sh

RUN chmod +x /start_influxdb.sh

ENTRYPOINT ["/bin/sh", "/start_influxdb.sh"] 