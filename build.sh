#!/bin/bash

declare -A build_array
build_array[php80]=8.0-fpm
build_array[php80-pgsql]=8.0-fpm
build_array[php74]=7.4-fpm
build_array[php74-pgsql]=7.4-fpm
build_array[php73]=7.3-fpm
build_array[php73-pgsql]=7.3-fpm

for tag in "${!build_array[@]}"
do
  
  unset DOCKER_IMAGE_VERSION
  unset DOCKER_TAG
  unset PGSQL_DEP
  unset PDO
  unset DB
  
  echo "key  : $tag"
  echo "value: ${build_array[$tag]}"
  export DOCKER_IMAGE_VERSION=${build_array[$tag]}
  export COMPOSER_VERSION=latest
  export DOCKER_TAG=$tag
  export PDO=pdo_mysql
  export DB=mysql
  
  if [[ $tag == *"pgsql"* ]]; then
    export PGSQL_DEP=libpq-dev
    export PDO=pdo_pgsql 
    export DB=pgsql
  fi

  docker-compose -f .docker-compose.yml-build build
done