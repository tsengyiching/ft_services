FROM alpine:latest

EXPOSE 5050

RUN apk update --no-cache
RUN apk upgrade --no-cache
RUN apk add nginx --no-cache
RUN apk add --no-cache php7 php7-fpm php7-opcache php7-gd php7-mysqli php7-zlib php7-curl php7-mbstring php7-json php7-session php-phar
RUN apk add openssl --no-cache
RUN apk add openssh --no-cache
RUN apk add wget
RUN apk add openrc
RUN apk add curl
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /usr/share/webapps/ && \
	cd /usr/share/webapps/ && \
	wget http://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	rm latest.tar.gz && \
	rm -f /usr/share/webapps/wordpress/wp-config.php && \
    cd ~

# Generate ssl certificate
RUN adduser -D -g www www
RUN mkdir -p /run/nginx /www /etc/nginx/ssl
RUN chown -R www:www /var/lib/nginx && chown -R www:www /www
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/default.key -out /etc/nginx/ssl/default.crt \
-subj "/C=FR/ST=France/L=Lyon/O=42student/CN=localhost"

# Install Telegraf
RUN apk add telegraf --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY srcs/setup.sh /
COPY srcs/wp-config.php /usr/share/webapps/wordpress/
COPY srcs/nginx.conf /etc/nginx/nginx.conf
COPY ./srcs/telegraf.conf /etc/telegraf/

RUN chmod +x /setup.sh

ENTRYPOINT ["/bin/sh", "/setup.sh"]