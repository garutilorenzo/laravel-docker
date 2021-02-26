#!/bin/bash

if [[ $composer_version == "1.x" ]]; then composer self-update --1; fi 
echo $composer_version
