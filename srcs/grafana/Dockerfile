FROM alpine:3.12
MAINTAINER Fabien Buthod-Garcon

RUN apk add --no-cache su-exec bash curl
RUN apk add libc6-compat gcompat

COPY srcs/start_grafana.sh /bin/start_grafana.sh
RUN chmod +x /bin/start_grafana.sh

WORKDIR /var/

ADD https://dl.grafana.com/oss/release/grafana-7.3.6.linux-amd64.tar.gz ./

RUN tar -C . -xzf grafana-7.3.6.linux-amd64.tar.gz && \
    chmod +x grafana-7.3.6 && \
    mv grafana-7.3.6 grafana

COPY srcs/grafana.db /var/grafana

EXPOSE 3000

ENTRYPOINT ["/bin/start_grafana.sh"]