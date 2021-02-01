FROM alpine:3.12
MAINTAINER Fabien Buthod-Garcon

RUN apk add --no-cache su-exec bash

COPY srcs/influxdb.conf /bin/influxdb.conf
COPY srcs/start_influxdb.sh /bin/start_influxdb.sh

RUN chmod +x /bin/start_influxdb.sh

WORKDIR /var/

ADD https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.3_linux_amd64.tar.gz ./

RUN tar -C . -xzf influxdb2-2.0.3_linux_amd64.tar.gz && \
    chmod +x influxdb2-2.0.3_linux_amd64 && \
    mv influxdb2-2.0.3_linux_amd64 influxdb && \
    rm -rf *.tar.gz* influxdb-*/

EXPOSE 8086

VOLUME [ "/var/influxdb" ]

ENTRYPOINT ["/bin/start_influxdb.sh"]