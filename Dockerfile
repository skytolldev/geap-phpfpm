FROM docker.io/alpine:latest

# install php84(,-fpm) and bash packages
RUN apk --no-cache add php84 php84-fpm bash
# address CVE-2022-3996
RUN apk --no-cache upgrade libssl3 libcrypto3

# install php84 extensions
RUN apk --no-cache add \
    php84-bcmath \
    php84-bz2 \
    php84-calendar \
    php84-ctype \
    php84-curl \
    php84-dom \
    php84-exif \
    php84-fileinfo \
    php84-ftp \
    php84-gd \
    php84-gettext \
    php84-iconv \
    php84-imap \
    php84-intl \
    php84-json \
    php84-ldap \
    php84-mbstring \
    php84-mysqli \
    php84-mysqlnd \
    php84-openssl \
    php84-pcntl \
    php84-pdo \
    php84-pdo_mysql \
    php84-pdo_pgsql \
    php84-pdo_sqlite \
    php84-pgsql \
    php84-phar \
    php84-posix \
    php84-session \
    php84-simplexml \
    php84-soap \
    php84-sockets \
    php84-sodium \
    php84-sqlite3 \
    php84-tokenizer \
    php84-xml \
    php84-xmlreader \
    php84-xmlwriter \
    php84-xsl \
    php84-zip \
    php84-zlib

# prepare local configuration structure
RUN mkdir -p /usr/local/etc/php84/conf.d
COPY conf/php-fpm.conf /usr/local/etc/php84/php-fpm.conf
RUN chown -R root: /usr/local/etc/php84
RUN chmod -R u=rwX,go=rX /usr/local/etc/php84

# install composer
# RUN apk --no-cache add composer
COPY bin/composer-install.sh /tmp/composer-install.sh
RUN chmod -R u=rwx,go=rx /tmp/composer-install.sh
RUN /tmp/composer-install.sh

# install npm
RUN apk --no-cache add npm

# prepare data volume mountpoint
RUN mkdir -p /srv/data

# volumes declarations
VOLUME /usr/local/etc/php84/conf.d
VOLUME /srv/data

# prepare entrypoint
COPY entrypoint.bash /usr/local/bin/entrypoint.bash
RUN chmod u=rwx,go=rx /usr/local/bin/entrypoint.bash

# create 'phpfpm' system user and group 
RUN addgroup -S phpfpm
RUN adduser -s /sbin/nologin -G phpfpm -D -H -S phpfpm

# create 'appusr' user and group
RUN addgroup -g 10000 appgrp
RUN adduser -u 10000 -G appgrp -D -H appusr
# add 'phpfpm' user to 'appgrp' group
RUN adduser phpfpm appgrp

# create php84 directory in /run and set ownership
RUN mkdir /run/phpfpm
RUN chown -R phpfpm: /run/phpfpm
RUN chmod -R u=rwX,go=rX /run/phpfpm

USER phpfpm
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
