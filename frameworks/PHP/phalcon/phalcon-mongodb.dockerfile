FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yqq software-properties-common > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -yqq > /dev/null && \
    apt-get install -yqq nginx git unzip \
        php7.4-cli php7.4-fpm php7.4-mysql php7.4-mbstring php7.4-mongodb > /dev/null

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY deploy/conf/* /etc/php/7.4/fpm/

ADD ./ /phalcon
WORKDIR /phalcon

RUN if [ $(nproc) = 2 ]; then sed -i "s|pm.max_children = 1024|pm.max_children = 512|g" /etc/php/7.4/fpm/php-fpm.conf ; fi;

RUN apt-get install -yqq php7.4-psr php7.4-phalcon  > /dev/null

RUN composer install --optimize-autoloader --classmap-authoritative --no-dev --quiet --ignore-platform-reqs

RUN mv /phalcon/public/index-mongo.php /phalcon/public/index.php

RUN chmod -R 777 app

EXPOSE 8080

CMD service php7.4-fpm start && \
    nginx -c /phalcon/deploy/nginx.conf
