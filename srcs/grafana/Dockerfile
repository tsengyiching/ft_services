FROM alpine:3.12

EXPOSE 3000

RUN apk add --no-cache su-exec bash curl
RUN apk add libc6-compat gcompat

# Install Telegraf
RUN apk add telegraf --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY srcs/start_grafana.sh /bin/start_grafana.sh
RUN chmod +x /bin/start_grafana.sh

WORKDIR /var/

ADD https://dl.grafana.com/oss/release/grafana-7.3.6.linux-amd64.tar.gz ./

RUN tar -C . -xzf grafana-7.3.6.linux-amd64.tar.gz && \
    chmod +x grafana-7.3.6 && \
    mv grafana-7.3.6 grafana && \
    rm grafana-7.3.6.linux-amd64.tar.gz

COPY srcs/dashboards /var/grafana/dashboards/
COPY srcs/dashboard.yaml /var/grafana/conf/provisioning/dashboards/
COPY srcs/datasources.yaml /var/grafana/conf/provisioning/datasources/
COPY srcs/telegraf.conf /etc/telegraf/
COPY srcs/grafana.ini /etc/

ENTRYPOINT ["/bin/start_grafana.sh"]