#!/bin/bash

if [ $# -lt 1 ] && [ $# -gt 4 ]; then
  echo "usage: $0 config-file [id] [iter stage]"
fi

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

cur_iter=1
stage=1

#set -x

if [ $# -eq 4 ]; then
  cur_iter=$3
  stage=$4
fi

mkdir -p $working/$id
mkdir -p $working/$id/LOGs

for i in `seq 1 $num_iters`; do
#  [ ! -f $working/$id/config.$i ] && (
      echo "id=$id" > $working/$id/config.$i
      echo "iter=$i" >> $working/$id/config.$i
      cat $config >> $working/$id/config.$i
#  )

  for j in `seq 1 6`; do
    [[ $cur_iter -lt $i || ( $cur_iter -eq $i && $stage -le $j ) ]] && $ROOT/scripts/$j.sh $working/$id/config.$i
  done
done
