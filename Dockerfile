FROM lnxtm/docker-cron
MAINTAINER Alexander Shevchenko <kudato@me.com>
#
ENV HTTP 80
ENV HTTPS 443
#
ENV FQDN example.com
ENV WWW_FQDN www.example.com
#
ENV FPM_ENABLE true
ENV PHP_MEMORY 128MB
ENV PHP_PM_MAX 4
ENV PHP_PM_START 1
ENV PHP_PM_SPARE_MIN 1
ENV PHP_PM_SPARE_MAX 2
#

#
ADD conf/https /https
ADD conf/http /http
ADD conf/localhost /localhost
#
ADD sh/le.sh /le.sh
ADD sh/pullnpush.sh /pullnpush.sh
ADD sh/entrypoint.sh /entrypoint.sh
#
RUN chmod +x /*.sh
# nginx and letsencrypt
RUN apt-get install -y nginx letsencrypt
RUN echo "[program:nginx]" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "command = /usr/sbin/nginx" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "user = root" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "autostart = true" >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /etc/nginx
ADD /conf/nginx /etc/nginx
RUN mkdir -p /etc/nginx/ssl && mkdir -p /usr/share/nginx/html && mkdir -p /etc/nginx/sites-enabled/
# php-fpm7.0
RUN apt-get install -y mysql-client php7.0-fpm php7.0-common php7.0-cli php-apcu \
	php-mbstring php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php-pear php-imagick \
	php7.0-imap php7.0-mcrypt php7.0-pspell php7.0-recode php-patchwork-utf8 php7.0-json \
	libxml-rss-perl zlib1g php7.0-sqlite php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-zip \
	php7.0-gd imagemagick && mkdir -p /run/php/
RUN	echo "[program:php-fpm7.0]" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "command = /usr/sbin/php-fpm7.0" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "user = root" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "autostart = true" >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /etc/php/7.0/fpm/php.ini && rm -rf /etc/php/7.0/fpm/pool.d/* && \
	rm -rf /etc/php/7.0/fpm/php-fpm.conf
ADD conf/php.ini /etc/php/7.0/fpm/php.ini
ADD conf/pool.conf /etc/php/7.0/fpm/pool.d/pool.conf
ADD conf/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf
# - >
CMD ["/entrypoint.sh"]
