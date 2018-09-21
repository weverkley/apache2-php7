FROM ubuntu:16.04
LABEL maintainer "Wever Kley <wever-kley@live.com>"
ENV DEBIAN_FRONTEND noninteractive

# Set the locale
RUN apt-get clean && apt-get update
RUN apt-get install locales

## Update locales
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

## Update linux and install basics
RUN apt-get install -y software-properties-common

## Add PHP repository
RUN add-apt-repository ppa:ondrej/php && apt-get update
RUN apt-get install -y curl

## Installs PHP
RUN apt-get install -y --no-install-recommends \
      apache2 \
      php7.2 \
      php7.2-cli \
      libapache2-mod-php7.2 \
      php-apcu \
      php-xdebug \
      php7.2-gd \
      php7.2-json \
      php7.2-ldap \
      php7.2-mbstring \
      php7.2-mysql \
      php7.2-pgsql \
      php7.2-sqlite3 \
      php7.2-xml \
      php7.2-xsl \
      php7.2-zip \
      php7.2-soap \
      php7.2-opcache \
	  php7.2-curl \
      composer

## Manually set up the apache environment variables
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

## Enable rewrite and php for apache
RUN a2enmod rewrite
RUN a2enmod php7.2

COPY apache_default /etc/apache2/sites-available/000-default.conf
COPY run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

## Backup and increase php upload size
RUN cp /etc/php/7.2/apache2/php.ini /etc/php/7.2/apache2/php.ini.bak
RUN sed -i 's,^upload_max_filesize =.*$,upload_max_filesize = 100M,' /etc/php/7.2/apache2/php.ini
RUN sed -i 's,^post_max_size =.*$,post_max_size = 100M,' /etc/php/7.2/apache2/php.ini
RUN sed -i 's,^max_input_time =.*$,max_input_time = 300,' /etc/php/7.2/apache2/php.ini
RUN sed -i 's,^max_execution_time =.*$,max_execution_time = 300,' /etc/php/7.2/apache2/php.ini


## Install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

## Add composer bin to PATH
ENV PATH "$PATH:$HOME/.composer/vendor/bin"

## Fix permissions for apache
RUN chown -R www-data:www-data /var/www

## Workdir
WORKDIR /var/www/html
# Remove default index page
# RUN rm index.html
# Use this command to copy your source code to apache
# this docker file is supossed to be on the root
# folder of your project
# COPY . /var/www/html

## Install dependencies
# If your project ues composer you can install
# its dependencies
# RUN composer install
RUN service apache2 restart

# Ports: apache2 http
EXPOSE 80

# Ports: apache2 https
EXPOSE 443

CMD ["/usr/local/bin/run"]