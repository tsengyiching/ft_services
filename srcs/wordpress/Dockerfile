FROM alpine:latest

EXPOSE 5050

RUN apk update --no-cache
RUN apk upgrade --no-cache
RUN apk add nginx --no-cache
RUN apk add --no-cache php7 php7-fpm php7-opcache php7-gd php7-mysqli php7-zlib php7-curl php7-mbstring php7-json php7-session
RUN apk add openssl --no-cache
RUN apk add openssh --no-cache
RUN apk add wget

RUN wget https://wordpress.org/wordpress-5.6.1.zip && \
    unzip wordpress-5.6.1.zip -d /www && \
    adduser -D -g 'www' www && \
    chown www:www /www/wordpress -R && \
    chmod -R -wx,u+rwX,g+rX,o+rX /www/wordpress

# Generate ssl certificate
RUN mkdir -p /run/nginx /www /etc/nginx/ssl
RUN chown -R www:www /var/lib/nginx && chown -R www:www /www
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/default.key -out /etc/nginx/ssl/default.crt \
-subj "/C=FR/ST=France/L=Lyon/O=42student/CN=localhost"

# Install Telegraf
RUN apk add telegraf --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY srcs/setup.sh /
COPY srcs/wp-config.php /www/wordpress/
COPY srcs/nginx.conf /etc/nginx/nginx.conf
COPY ./srcs/telegraf.conf /etc/telegraf/

RUN chmod +x /setup.sh

ENTRYPOINT ["/bin/sh", "/setup.sh"]