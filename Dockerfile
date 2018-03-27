FROM php:7.1.14-fpm

ENV node_version 8.4.0
ENV npm_version 5.7.1
ENV NVM_DIR /.nvm
ENV APP_DIR="/app"
ENV APP_PORT="8081"

RUN echo "deb http://ftp.de.debian.org/debian stretch main " >> /etc/apt/sources.list \
&& apt-get update -y && apt-get install -y openssl zip unzip git automake \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libmagickwand-dev vim --no-install-recommends \
&& apt-get remove -y libgnutls-deb0-28 \
&& apt-get purge --auto-remove -y g++ \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
&& docker-php-ext-install pdo pdo_mysql mbstring zip -j$(nproc) iconv mcrypt -j$(nproc) gd

# the "app" directory (relative to Dockerfile) containers your Laravel app...
COPY . $APP_DIR

RUN curl -sS https://getcomposer.org/installer | php -- \
  --install-dir=/usr/bin --filename=composer

RUN cd $APP_DIR && composer install

WORKDIR $APP_DIR
CMD php artisan serve --host=0.0.0.0 --port=$APP_PORT
