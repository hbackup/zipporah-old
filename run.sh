#!/bin/bash

if [ $# -ne 1 ]; then
  echo usage: $0 config-file
fi

config=$1

. $config

echo working is $working 
mkdir -p $working/

id=`ls $working | sort -nr | head -n 1`
if [ "$id" == "" ]; then
  id=-1
fi

id=$[$id+1]

mkdir $working/$id
mkdir $working/$id/LOGs

echo "id=$id" > $working/$id/config
cat $config >> $working/$id/config

$ROOT/scripts/1.sh $working/$id/config

