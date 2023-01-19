ARG DOCKER_IMAGE_VERSION
FROM php:${DOCKER_IMAGE_VERSION}

ARG PGSQL_DEP

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
    bash \
    tzdata ${PGSQL_DEP}

ARG PDO
ARG DOCKER_IMAGE_VERSION

# Install extensions
RUN docker-php-ext-install ${PDO} zip exif pcntl
COPY ./laravel/php-configure.sh /
RUN /php-configure.sh && rm -rf /php-configure.sh
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ARG COMPOSER_VERSION
COPY ./laravel/composer.sh /
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

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


ENV LANG it_IT.UTF-8
ENV LANGUAGE it_IT:it
ENV LC_ALL it_IT.UTF-8

ARG DB

COPY ./laravel/docker-entrypoint-${DB}.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

COPY ./laravel/wait-${DB}.php /usr/local/bin/

# Set working directory
VOLUME /var/www/html

# Change current user to www
USER app 

CMD ["php-fpm"]