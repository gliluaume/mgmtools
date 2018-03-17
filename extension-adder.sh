#!/usr/bin/env bash

for file in $(find ${1} -type f -regextype sed -regex ".*[^${2}]")
do
  mv ${file} ${file}.$2;
done
