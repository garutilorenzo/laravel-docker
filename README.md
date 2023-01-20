# laravel-docker

[![Laravel CI](https://github.com/garutilorenzo/laravel-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/garutilorenzo/laravel-docker/actions/workflows/ci.yml)
[![GitHub issues](https://img.shields.io/github/issues/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/issues)
![GitHub](https://img.shields.io/github/license/garutilorenzo/laravel-docker)
[![GitHub forks](https://img.shields.io/github/forks/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/network)
[![GitHub stars](https://img.shields.io/github/stars/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/stargazers)

![Laravel Logo](https://garutilorenzo.github.io/images/laravel.png)

### How to use this repository

#### Build the images (optional)

In the directory [build-env-files](build-env-files/) you will find the build environment variables for:

* php-fpm
* alpine
* ubuntu

and for each base image you can build the final image with: php 8, php 7.4 and php 7.3.
On each *php version* subdir you will find two *build env files* one for MySQL and one for PgSQL

To build the images from scratch you can run the following command:

```console
docker-compose --env-file build-env-files/php-fpm/8/.env-pgsql -f build-phpfpm.yml build # --pull <- Use '--pull' if you want to update the base image 
```

In this case the final image will be tagged with *localbuild/laravel-docker:php80-pgsql*, you can then push the newly builded image in your registry.

The supported build variables are:

| Var   | Desc |
| -------         | ----------- |
| `LARAVEL_VERSION`    | Laravel version to be included in the builded image |
| `DOCKER_IMAGE_VERSION`    | PHP base image version to use |
| `COMPOSER_VERSION`    | Composer version to use |
| `PDO`    | PDO to install, pdo_mysql or pdo_pgsql |
| `PGSQL_DEP`    | Extra dependency fo Postgresql (optional, required for pgsql images)|

Specific build variables needed only for Ubuntu:

| Var   | Desc |
| -------         | ----------- |
| `PHP_VERSION`    | Version of php to use |
| `PHP_SHA256`    | SHA256 signature of the PHP package |
| `GPG_KEYS`    | GPG keys of the PHP package |

There are a couple of "hard coded" variables inside the Dockerfile.
The variables are:

* TZ: this variable set the timezone
* LANG, LANGUAGE, LC_ALL: these variable set the locale of the container

Also to adjust the locale you have to modify this line "sed -i -e 's/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/' /etc/locale.gen" with the locale you need.

#### Bring up test or prod env

There are 2 differente docker-compose.yml:

* docker-compose.yml-dev: Test environment
* docker-compose.yml-prod: Production environment

Other configurations files:

* .env files contain variables used by docker-compose.yml, adjust with your personal settings.
* config directory contains nginx configurations (only for prod environment). Adjust domain with your own domain
* init_letsencrypt.sh (optional): initializes a custom ssl certificate used by nginx on the very first initlialization of the prod enviroment

### Variables

Laravel container accepts the following env variables:

| Var   | Desc |
| -------         | ----------- |
| `LARAVEL_DB_HOST`    | MySQL or Postgresql host |
| `FORCE_MIGRATE`    | Tells Laravel to run php artisan migrate --force at startup |
| `FORCE_COMPOSER_UPDATE`    | Tells Laravel to run composer update at startup |
| `CONTAINER_ROLE`    | Role of the laravel container, valid values are: queue, scheduler, app (default) |
| `QUEUE_NAME`    | Name of the queue, required if the container is launched with CONTAINER_ROLE=queue |

MySQL variables:

| Var   | Desc |
| -------         | ----------- |
| `MYSQL_USER`    | MySQL user  |
| `MYSQL_PASSWORD`    | MySQL password |
| `MYSQL_DATABASE`    | MySQL database |

PgSQL variables:

| Var   | Desc |
| -------         | ----------- |
| `PGSQL_USER`    | Postgresql user |
| `PGSQL_PASSWORD`    | Postgresql password |
| `PGSQL_DB`    | Postgresql password |

### Setup test or prod env

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

### Queue and Scheduler containers

You can run the laravel container as:

* app. Run laravel to expose http applications (default)
* queue container. More details [here](https://laravel.com/docs/8.x/queues)
* scheduler container. More details [here](https://laravel.com/docs/8.x/scheduling#running-the-scheduler)

An example of running laravel container as queue container is:

```yaml
queue_default:
    image: garutilorenzo/laravel:php74-pgsql
    build:
      context: laravel/
    container_name: queue_default
    volumes:
      - ${LARAVEL_DATA_DIR:-./laravel-project}:/var/www/html
    environment:
      - MYSQL_USER=${LARAVEL_DB_USER:-app}
      - MYSQL_PASSWORD=${LARAVEL_DB_USER:-password}
      - MYSQL_DATABASE=${LARAVEL_DB_NAME:-laravel}
      - LARAVEL_DB_HOST=${LARAVEL_DB_HOST:-mysql}
      - CONTAINER_ROLE=queue
      - QUEUE_NAME=default     
    depends_on:
      - pgsql
      - laravel
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
        max-file: "5"
    restart: always
```
You can launch as many queue container as you want. You have only to:

* give an unique service name and unique container name
* spcify the environment variables:
  * CONTAINER_ROLE=quque to start the container as queue container
  * QUEUE_NAME=<queue_name> to specify the queue name

The final command launched inside the container is for example:

```
php artisan queue:work database --queue=$QUEUE_NAME --verbose --tries=3
```

An example of running laravel container as scheduler container is:

```yaml
scheduler:
    image: garutilorenzo/laravel:php74-pgsql
    build:
      context: laravel/
    container_name: scheduler
    volumes:
      - ${LARAVEL_DATA_DIR:-./laravel-project}:/var/www/html
    environment:
      - MYSQL_USER=${LARAVEL_DB_USER:-app}
      - MYSQL_PASSWORD=${LARAVEL_DB_USER:-password}
      - MYSQL_DATABASE=${LARAVEL_DB_NAME:-laravel}
      - LARAVEL_DB_HOST=${LARAVEL_DB_HOST:-mysql}
      - CONTAINER_ROLE=scheduler
    depends_on:
      - pgsql
      - laravel
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
        max-file: "5"
    restart: always
```

the main part here is "CONTAINER_ROLE=scheduler", with this option the container starts an infinite loop an run the above command:

```
while [ true ]
do
  php artisan schedule:run --verbose --no-interaction &
  sleep 60
done
```

### Enable SSL (optional)

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

### Notes

* MySQL sotre persistent data on mysql volume. The volume persist until command docker-compose down -v is gived.
* Laravel docker image contains laravel v. 8.5.9. To persist your work download the laravel version you desire and extract the archive in laravel-project dir (at the same lavel on docker-compose.yml).
* The name of the persistent directory of laravel (laravel-project) can be changed in .env file
* To import existing database create sql/ directory at the same level of docker-compose.yml and uncomment "./slq:/docker-entrypoint-initdb.d" in the volume sections of the mysql service.
* FORCE_MIGRATE environment variable (ose only on laravel service) whill force laravel to force migrations "php artisan migrate --force"
* laravel container creates a .env enviroment file (laravel-project/.env) if no .env file exist. The file is created based on the enviroment varialbes attached to laravel service (MYSQL_USER, MYSQL_PASSWORD..). if .env file is found the file wont't be recreated/overwritten. If you provide an existing .env laravel file adjust to work wiht mysql container service.
