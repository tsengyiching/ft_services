FROM alpine:3.12

EXPOSE 8086

RUN apk add --no-cache su-exec bash
# Install Telegraf
RUN apk add telegraf --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY srcs/influxdb.conf /bin/influxdb.conf
COPY srcs/start_influxdb.sh /bin/start_influxdb.sh
COPY srcs/telegraf.conf /etc/telegraf/

RUN chmod +x /bin/start_influxdb.sh

WORKDIR /var/lib/

ADD https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.3_linux_amd64.tar.gz ./

RUN tar -C . -xzf influxdb2-2.0.3_linux_amd64.tar.gz && \
    chmod +x influxdb2-2.0.3_linux_amd64 && \
    mv influxdb2-2.0.3_linux_amd64 influxdb && \
    rm -rf *.tar.gz* influxdb-*/ 

VOLUME [ "/var/lib/influxdb" ]

ENTRYPOINT ["/bin/start_influxdb.sh"]