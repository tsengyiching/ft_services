FROM alpine:3.12

EXPOSE 8086

RUN apk update --no-cache
RUN apk upgrade --no-cache
RUN apk add influxdb --no-cache
RUN apk add telegraf --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY srcs/influxdb.conf /etc/influxdb.conf
COPY srcs/start_influxdb.sh /bin/start_influxdb.sh
COPY srcs/telegraf.conf /etc/telegraf/

RUN chmod +x /bin/start_influxdb.sh

ENTRYPOINT ["/bin/start_influxdb.sh"] 