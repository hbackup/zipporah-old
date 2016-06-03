#!/bin/bash

if [ $# -ne 2 ]; then
  echo "usage: $0 config-file id"
fi

config=$1
id=$2

. $config

set -v

n=`wc -l $raw_stem_bad.$input | awk '{print$1}'`
echo n is $n

for k in 500000 1000000 2000000 3000000; do
  echo generating random $k
  mkdir -p $working/$id/rand-$k-$input-$output
  $ROOT/tools/get-rand-index $n $k > $working/$id/rand-$k-$input-$output/index
  for i in $input $output; do
    $ROOT/tools/get-lines $working/$id/rand-$k-$input-$output/index $raw_stem_bad.$i > $working/$id/rand-$k-$input-$output/train.$i
  done
  wc $working/$id/rand-$k-$input-$output/train.??
done
