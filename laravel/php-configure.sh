#!/bin/bash

if [[ $DOCKER_IMAGE_VERSION == "7.3-fpm" ]]; then docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr; else docker-php-ext-configure gd --enable-gd -with-freetype --with-jpeg; fi 
echo $DOCKER_IMAGE_VERSION