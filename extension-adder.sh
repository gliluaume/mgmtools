#!/usr/bin/env bash

for file in $(ls -1 ${1})
do
  mv ${file} ${file}.$2;
done
