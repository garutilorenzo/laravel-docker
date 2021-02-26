FROM php:8.0-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    libzip-dev \
    zip \
    git \
    jpegoptim optipng pngquant gifsicle \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

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
RUN groupadd -g 1000 app && useradd -u 1000 -g 1000 -m -d /var/www/html -s /bin/bash app && usermod -a -G www-data app

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
