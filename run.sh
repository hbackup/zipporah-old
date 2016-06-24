#!/bin/bash

if [ $# -lt 1 ] && [ $# -gt 3 ]; then
  echo "usage: $0 config-file [id] [stage]"
fi

config=$1
id=

. $config

mkdir -p $working/

if [ $# -eq 1 ]; then
  id=`ls $working | sort -nr | head -n 1`
  if [ "$id" == "" ]; then
    id=0
  fi

  id=$[$id+1]
else
  id=$2
fi

stage=0

if [ $# -eq 3 ]; then
  stage=$3
fi

mkdir -p $working/$id
mkdir -p $working/$id/LOGs

echo "id=$id" > $working/$id/config
cat $config >> $working/$id/config

[ $stage -le 1 ] && $ROOT/scripts/1.sh $working/$id/config
[ $stage -le 2 ] && $ROOT/scripts/2.sh $working/$id/config

[ $stage -le 3 ] && $ROOT/scripts/3.sh $working/$id/config
[ $stage -le 4 ] && $ROOT/scripts/4.sh $working/$id/config
[ $stage -le 5 ] && $ROOT/scripts/5.sh $working/$id/config
[ $stage -le 6 ] && $ROOT/scripts/6.sh $working/$id/config
