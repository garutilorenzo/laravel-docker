ARG DOCKER_IMAGE_VERSION
FROM php:${DOCKER_IMAGE_VERSION}

ARG PGSQL_DEP

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libfreetype6 \
    locales \
    libzip-dev \
    libzip4 \
    libpng16-16 \
    libjpeg62-turbo \
    zip \
    git \
    jpegoptim optipng pngquant gifsicle \
    curl locales ${PGSQL_DEP}

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

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
RUN groupadd -g 1000 app && useradd -u 1000 -g 1000 -m -d /var/www/html -s /bin/bash app && usermod -a -G www-data app

WORKDIR /root/

ARG LARAVEL_VERSION
RUN rm -rf /var/www/html \
    && curl -SLJ https://github.com/laravel/laravel/archive/v${LARAVEL_VERSION}.tar.gz  | tar -zxC /root/ \
    && mv /root/laravel-${LARAVEL_VERSION} /var/www/html \
    && chown -R www-data:www-data /var/www \
    && rm -rf /root/laravel-${LARAVEL_VERSION}

ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c

# persistent / runtime deps
RUN set -eux; \
	apt-get -y remove --purge \
		$PHPIZE_DEPS \
		xz-utils \
        binutils-common \
        openssh-client \
        linux-libc-dev \
        libc-dev-bin \
        libgcc-8-dev \
        libc6-dev \
        dpkg-dev \
	; \
    apt-get -y autoremove; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN sed -i -e 's/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

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
