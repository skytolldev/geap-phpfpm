FROM docker.io/alpine:3.17

# install php81(,-fpm) and bash packages
RUN apk --no-cache add php81 php81-fpm bash
# address CVE-2022-3996
RUN apk --no-cache upgrade libssl3 libcrypto3

# install php81 extensions
RUN apk --no-cache add php81-bcmath \
  php81-ctype            \
  php81-curl             \
  php81-dom              \
  php81-fileinfo         \
  php81-mbstring         \
  php81-openssl          \
  php81-pdo              \
  php81-pdo_mysql        \
  php81-session          \
  php81-simplexml        \
  php81-tokenizer        \
  php81-xml              \
  php81-xmlreader        \
  php81-xmlwriter

# install composer
RUN apk --no-cache add composer

# install npm
RUN apk --no-cache add npm

# prepare local configuration structure
RUN mkdir -p /usr/local/etc/php81/conf.d
COPY conf/php-fpm.conf /usr/local/etc/php81/php-fpm.conf
RUN chown -R root: /usr/local/etc/php81
RUN chmod -R u=rwX,go=rX /usr/local/etc/php81

# prepare data volume mountpoint
RUN mkdir -p /srv/data

# volumes declarations
VOLUME /usr/local/etc/php81/conf.d
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

# create php81 directory in /run and set ownership
RUN mkdir /run/phpfpm
RUN chown -R phpfpm: /run/phpfpm
RUN chmod -R u=rwX,go=rX /run/phpfpm

USER phpfpm
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
