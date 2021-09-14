#!/bin/bash

if [[ $COMPOSER_VERSION == "1.x" ]]; then composer self-update --1; fi 
echo $COMPOSER_VERSION