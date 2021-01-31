FROM alpine:latest

EXPOSE 5050

RUN apk update --no-cache
RUN apk upgrade --no-cache
RUN apk add openssl --no-cache
RUN apk add wget
RUN apk add php7 php7-fpm php7-opcache \
php7-gd php7-mysqli php7-zlib php7-curl \
php7-mbstring php7-json php7-session

RUN wget https://fr.wordpress.org/wordpress-latest-fr_FR.zip && \
    unzip wordpress-latest-fr_FR.zip -d /www && \
    adduser -D -g 'www' www && \
    chown www:www /www/wordpress -R && \
    chmod -R -wx,u+rwX,g+rX,o+rX /www/wordpress

COPY srcs/setup.sh /

RUN chmod +x /setup.sh

ENTRYPOINT ["/bin/sh", "/setup.sh"]