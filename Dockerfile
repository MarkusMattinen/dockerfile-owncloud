# owncloud, nginx, etcd registration, confd and supervisord on trusty
#
# Includes php-fpm, cron job support and PostgreSQL support
FROM markusma/nginx-etcdregister:1.7
MAINTAINER Markus Mattinen <docker@gamma.fi>

RUN apt-get update \
 && apt-get install -y --no-install-recommends php5-fpm php5-pgsql php5-mysql php5-intl php5-gd php-xml-parser php5-curl cron \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV OWNCLOUD_VERSION 8.0.3

RUN cd /tmp \
 && curl -sSL http://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 > owncloud-${OWNCLOUD_VERSION}.tar.bz2 \
 && curl -sSL http://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.md5 > owncloud-${OWNCLOUD_VERSION}.tar.bz2.md5 \
 && cat owncloud-${OWNCLOUD_VERSION}.tar.bz2 | md5sum --check --strict owncloud-${OWNCLOUD_VERSION}.tar.bz2.md5 \
 && cd /var/www \
 && tar jxf /tmp/owncloud-${OWNCLOUD_VERSION}.tar.bz2 \
 && chown -R www-data:www-data /var/www/owncloud \
 && rm -rf /tmp/*

ADD config/etc/crontab /etc/crontab
ADD config/etc/nginx/server.conf /etc/nginx/server.conf
ADD config/etc/php5 /etc/php5
ADD config/etc/supervisor/conf.d /etc/supervisor/conf.d
ADD config/init /init
ADD config/var/www/owncloud/.user.ini /var/www/owncloud/.user.ini

RUN cd /var/www/owncloud \
 && sed -i 's/php_value upload_max_filesize .*/php_value upload_max_filesize 10G/' .htaccess \
 && sed -i 's/php_value post_max_size .*/php_value post_max_size 10G/' .htaccess \
 && sed -i 's/php_value memory_limit .*/php_value memory_limit 4G/' .htaccess

VOLUME ["/var/www/owncloud/data", "/var/www/owncloud/config"]
EXPOSE 5000
