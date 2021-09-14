# laravel-docker

[![Laravel CI](https://github.com/garutilorenzo/laravel-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/garutilorenzo/laravel-docker/actions/workflows/ci.yml)
[![GitHub issues](https://img.shields.io/github/issues/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/issues)
![GitHub](https://img.shields.io/github/license/garutilorenzo/laravel-docker)
[![GitHub forks](https://img.shields.io/github/forks/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/network)
[![GitHub stars](https://img.shields.io/github/stars/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/stargazers)

![Laravel Logo](https://garutilorenzo.github.io/images/laravel.png)

#### How to use this repository

There are 3 branch. Each branch contains a different base image.
On each branch then you can find a "build matrix" in build.sh
Switch to the branch with the base image you prefer and build the images, or download images directly from https://hub.docker.com/

The branches are:

* master: official php images
* alpine: official php alpine images
* ubuntu: ubuntu official images + php

on each branch you can find a build.sh. This file builds:

* on the master branch:
  * php80: Laravel docker image with official PHP 8.0 and MySQL PDO
  * php80-pgsql: Laravel docker image with official PHP 8.0 and PgSQL PDO
  * php74: Laravel docker image with official PHP 7.4 and MySQL PDO
  * php74-pgsql: Laravel docker image with official PHP 7.4 and PgSQL PDO
  * php73: Laravel docker image with official PHP 7.3 and MySQL PDO
  * php73-pgsql: Laravel docker image with official PHP 7.3 and PgSQL PDO
* on the alpine branch:
  * alpine-php80: Laravel docker image with official PHP 8.0 Alpine and MySQL PDO
  * alpine-php80-pgsql: Laravel docker image with official PHP Alpine 8.0 and PgSQL PDO
* on the ubuntu branch:
  * ubuntu-php80: Laravel docker image with official Ubuntu image + PHP 8.0 and MySQL PDO
  * ubuntu-php80-pgsql: Laravel docker image with official Ubuntu image + PHP 8.0 and PgSQL PDO
  * ubuntu-php74: Laravel docker image with official Ubuntu image + PHP 7.4 and MySQL PDO
  * ubuntu-php74-pgsql: Laravel docker image with official Ubuntu image + PHP 7.4 and PgSQL PDO
  * ubuntu-php73: Laravel docker image with official Ubuntu image + PHP 7.3 and MySQL PDO
  * ubuntu-php73-pgsql: Laravel docker image with official Ubuntu image + PHP 7.3 and PgSQL PDO

There are 2 differente docker-compose.yml:

* docker-compose.yml-dev: Test environment
* docker-compose.yml-prod: Production environment

Other configurations files:

* .env files contain variables used by docker-compose.yml, adjust with your personal settings.
* config directory contains nginx configurations (only for prod environment). Adjust domain with your own domain
* init_letsencrypt.sh (optional): initializes a custom ssl certificate used by nginx on the very first initlialization of the prod enviroment

#### Variables

Environment variables:

* MYSQL_USER: MySQL user
* MYSQL_PASSWORD: MySQL password
* MYSQL_DATABASE: MySQL database
* PGSQL_USER: Postgresql user
* PGSQL_PASSWORD: Postgresql password
* PGSQL_DB: Postgresql database
* LARAVEL_DB_HOST: MySQL or Postgresql host
* FORCE_MIGRATE: Tells laravel to run php artisan migrate --force at startup
* FORCE_COMPOSER_UPDATE: Tells laravel to run composer update at startup
* CONTAINER_ROLE: Role of the laravel container, valid values are:
  * queue: Run laravel as queue container
  * scheduler: Run laravel as scheduler container
  * app: Run laravel to expose http applications
* QUEUE_NAME: Name of the queue, required if the container is launched with CONTAINER_ROLE=queue

Build arguments:

* DOCKER_IMAGE_VERSION: PHP base image version to use
* COMPOSER_VERSION: Composer version to use
* PDO: PDO to install, pdo_mysql or pdo_pgsql
* DB: DB type, mysql or pgsql
* PGSQL_DEP: Extra dependency fo Postgresql (optional, required for pgsql images)

Build arguments used only in the "ubuntu" branch:

* PHP_VERSION: Version of php to use
* PHP_SHA256: SHA256 signature of the PHP package
* GPG_KEYS: GPG keys of the PHP package

There are a couple of "hard coded" variables inside the Dockerfile.
The variables are:

* TZ: this variable set the timezone
* LANG, LANGUAGE, LC_ALL: these variable set the locale of the container

Also to adjust the locale you have to modify this line "sed -i -e 's/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/' /etc/locale.gen" with the locale you need.

#### Setup test or prod env

For testing purposes copy docer-compose.yml-dev in docker-compose.yml, fire up the enviromnent with:

```console
docker-compose up -d
```

Laravel will be exposed on port 3000 (localhost)

For production enviroment copy docer-compose.yml-prod in docker-compose.yml.

Adjust domain name in config/nginx/conf.d/example.conf (rename the file with appropriate name)
Fire up the enviromnent with:

```console
docker-compose up -d
```

Nginx will be exposed on port 80 and 443 of your host

#### Enable SSL (optional)

A configuration example is placed on config/nginx/conf.d/example.conf-ssl (rename the file with appropriate name, and delete/rename example.conf file)
Remember to uncomment certbot service in docker-compose.yml-prod.

If you have to create a new SSL certificate using Let's Encrypt, modify init_letsencrypt.sh with your domain(s) name(s) and change the email variable.
Require the new certificate with:

```console
bash init_letsencrypt.sh
```
For nginx auto reload, uncomment the *command* on the nginx service. This is necessary for auto reload nginx when certot renew the ssl certificates.


If you have your own SSL certificate modifiy config/nginx/conf.d/example.conf-ssl and docker-compose-yml-prod based on your needs (adjust the path to the certificates)

You can now start the services with:

```console
docker-compose up -d
```

#### Notes

* MySQL sotre persistent data on mysql volume. The volume persist until command docker-compose down -v is gived.
* Laravel docker image contains laravel v. 8.5.9. To persist your work download the laravel version you desire and extract the archive in laravel-project dir (at the same lavel on docker-compose.yml).
* The name of the persistent directory of laravel (laravel-project) can be changed in .env file
* To import existing database create sql/ directory at the same level of docker-compose.yml and uncomment "./slq:/docker-entrypoint-initdb.d" in the volume sections of the mysql service.
* FORCE_MIGRATE environment variable (ose only on laravel service) whill force laravel to force migrations "php artisan migrate --force"
* laravel container creates a .env enviroment file (laravel-project/.env) if no .env file exist. The file is created based on the enviroment varialbes attached to laravel service (MYSQL_USER, MYSQL_PASSWORD..). if .env file is found the file wont't be recreated/overwritten. If you provide an existing .env laravel file adjust to work wiht mysql container service.
