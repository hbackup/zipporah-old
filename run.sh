#!/bin/bash

if [ $# -ne 1 ]; then
  echo usage: $0 config-file
fi

config=$1

. $config

id=`ls $working | sort -nr | head -n 1`
id=$[$id+1]

mkdir $working/$id/

echo "id=$id" > $config
cat $config >> $working/$id/config

$ROOT/scripts/1.sh $working/$id/config

