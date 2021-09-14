#!/bin/bash

DOCKER_HUB_REPO="garutilorenzo/laravel"

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
  
  LOCAL_TAG="localbuild/laravel-docker-ci:${tag}"

  docker tag $LOCAL_TAG $DOCKER_HUB_REPO:${tag}
  docker push $DOCKER_HUB_REPO:${tag}

  if [[ $tag == "php80" ]]; then
   docker tag $LOCAL_TAG $DOCKER_HUB_REPO:"latest"
   docker push $DOCKER_HUB_REPO:"latest"
  fi
done