# laravel-docker

[![Laravel CI](https://github.com/garutilorenzo/laravel-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/garutilorenzo/laravel-docker/actions/workflows/ci.yml)
[![GitHub issues](https://img.shields.io/github/issues/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/issues)
![GitHub](https://img.shields.io/github/license/garutilorenzo/laravel-docker)
[![GitHub forks](https://img.shields.io/github/forks/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/network)
[![GitHub stars](https://img.shields.io/github/stars/garutilorenzo/laravel-docker)](https://github.com/garutilorenzo/laravel-docker/stargazers)

![Laravel Logo](https://garutilorenzo.github.io/images/laravel.png)

#### How to use this repository

There are 3 branch. Each branch contains a different version of php-fpm.
Switch to the branch with the correct php version upon your needs.

Ther are 2 differente docker-compose.yal:

* docker-compose.yml-dev: Test environment
* docker-compose.yml-prod: Production environment

Other configurations files:

* .env files contain variables used by docker-compose.yml, adjust with your personal settings.
* config directory contains nginx configurations (only for prod environment). Adjust domain with your own domain
* init_letsencrypt.sh (optional): initializes a custom ssl certificate used by nginx on the very first initlialization of the prod enviroment


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

**Enable SSL (optional)**

A configuration example is placed on config/nginx/conf.d/example.conf-ssl (rename the file with appropriate name, and delete/rename example.conf file)
Remember to uncomment certbot service in docker-compose.yml-prod.
Modify init_letsencrypt.sh with your domain(s) name(s) and change the email variable.
For nginx auto reload, uncomment the *command* on the nginx service. This is necessary for auto reload nginx when certot renew the ssl certificates.

Before turn on docker services run bash init_letsencrypt.sh after that turn on services with:

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
