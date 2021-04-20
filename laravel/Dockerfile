FROM php:8.0-alpine

# Install dependencies

RUN apk add --no-cache \
    freetype \
    libpng \
    libzip-dev \
    libjpeg-turbo \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    zip \
    git \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    curl \
    bash

# Install extensions
RUN docker-php-ext-install pdo_mysql zip exif pcntl
RUN docker-php-ext-configure gd --enable-gd -with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV composer_version latest

COPY ./composer.sh /
RUN /composer.sh && rm -rf /composer.sh

# Add user for laravel application
RUN addgroup --gid 1000 app && \
    adduser \
    --disabled-password \
    --gecos "" \
    --home /var/www/html \
    --ingroup app \
    --no-create-home \
    --uid 1000 \
    app && \
    addgroup app www-data

WORKDIR /root/

ENV laravel_version 8.5.9
RUN rm -rf /var/www/html \
    && curl -SLJ https://github.com/laravel/laravel/archive/v$laravel_version.tar.gz  | tar -zxC /root/ \
    && mv /root/laravel-$laravel_version /var/www/html \
    && chown -R www-data:www-data /var/www \
    && rm -rf /root/laravel-$laravel_version

WORKDIR /var/www/html/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

COPY wait-mysql.php /usr/local/bin/

# Set working directory
VOLUME /var/www/html

# Change current user to www
USER app 

CMD ["php-fpm"]
