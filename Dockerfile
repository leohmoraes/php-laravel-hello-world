FROM php:7.1-fpm-alpine

RUN apk update && apk add curl && \
  curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar && mv composer.phar /usr/local/bin/composer

RUN apk --no-cache add --virtual .build-deps $PHPIZE_DEPS \
  && apk --no-cache add --virtual .ext-deps libmcrypt-dev freetype-dev \
  libjpeg-turbo-dev libpng-dev libxml2-dev msmtp bash openssl-dev pkgconfig \
  && docker-php-source extract \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
                                   --with-png-dir=/usr/include/ \
                                   --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd mcrypt mbstring mysqli pdo pdo_mysql zip opcache \
  && pecl install redis xdebug \
  && docker-php-ext-enable redis \
  && docker-php-ext-enable xdebug \
  && docker-php-source delete \
  && apk del .build-deps

WORKDIR /var/www/html

COPY composer.json ./
RUN composer install --no-scripts --no-autoloader

COPY . .
RUN chmod +x artisan

RUN composer dump-autoload --optimize && composer run-script post-install-cmd

EXPOSE 80
ENTRYPOINT ["/bin/sh", "-c"]

#ENTRYPOINT ["/usr/share/docker-laravel/bin/start.sh"]

# CMD bash -c "composer install && php artisan serve --host 0.0.0.0 --port 5001"
# CMD bash -c "php artisan serve --host 0.0.0.0 --port 5001"
