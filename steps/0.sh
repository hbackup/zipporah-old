#!/bin/bash

function file_exist {
  if [ ! -f $1 ]; then
    exit -1
  fi
}

echo $0: check if config file is valid

set -e

mkdir -p $working

file_exist 



