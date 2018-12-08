#!/usr/bin/env bash

function assertInt(){
  if [[ $1 -ne $2 ]]
  then
    echo "FAIL $1 expected to equal $2. $3"
    exit 50
  fi
}

function assertString(){
  if [[ -z $1 ]]
  then
    echo "FAIL first parameter is null. $3"
    exit 48
  fi

  if [[ -z $2 ]]
  then
    echo "FAIL second parameter is null. $3"
    exit 49
  fi

  if [[ $1 != $2 ]]
  then
    echo "FAIL $1 expected to equal $2. $3"
    exit 50
  fi
}

function assertTrue(){
  if [[ $1 != true ]]
  then
    echo "FAIL $1 expected to be true. $2"
    exit 50
  fi
}

if [[ "$BASH_ENV" == "UNIT_TEST" ]]
then
  echo "running unit tests on $BASH_SOURCE through ${0##*/}"
  assertTrue true "does not work on bool"
  assertInt 1 1 "does not work on int"
  assertString "a" "a" "does not work on string"
fi