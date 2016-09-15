#!/bin/bash

export LC_ALL=C
export LANGUAGE=C

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  echo "usage: $0 config-file [id] [stage]"
  exit 1
fi

set -e

config=$1
id=

. $config

mkdir -p $working/

# working out the experiment id
if [ $# -eq 1 ]; then
  id=`ls $working | sort -nr | head -n 1`
  if [ "$id" == "" ]; then
    id=0
  fi
  id=$[$id+1]
else
  id=$2
fi

stage=1

#set -x

if [ $# -eq 3 ]; then
  stage=$3
fi

mkdir -p $working/$id
mkdir -p $working/$id/LOGs

#  [ ! -f $working/$id/config.$i ] && (
      echo "id=$id" > $working/$id/config
      echo "iter=$i" >> $working/$id/config
      cat $config >> $working/$id/config
#  )

  for j in `seq 1 5`; do
    [ $stage -le $j ] && $ROOT/scripts/$j.sh $working/$id/config
  done
