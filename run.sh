#!/bin/bash

if [ $# -ne 1 ]; then
  echo usage: $0 config-file
fi

config=$1

. $config

$ROOT/scripts/1.sh $config

