#!/bin/bash

config=$1

id=$2
k=$3

. $config

set -v

f=
prefix=

if [ "$clean_stem_bad" != "" ]; then
  f=$clean_stem_bad.$input_lang
  prefix=$clean_stem_bad
else
  f=$raw_stem_bad.$input_lang
  prefix=$raw_stem_bad
fi


n=`wc -l $f | awk '{print$1}'`

mkdir -p $working/$id

$ROOT/tools/get-rand-index $n $k > $working/$id/index.$k

$ROOT/tools/get-lines $working/$id/index.$k $prefix.$input_lang > $working/$id/rand.$k.$input_lang
$ROOT/tools/get-lines $working/$id/index.$k $prefix.$output_lang > $working/$id/rand.$k.$output_lang

