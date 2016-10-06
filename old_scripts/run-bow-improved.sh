#!/bin/bash

config=$1
unigram=$2
dict=$3
source=$4
target=$5

file=`basename $dict`

. $config

mkdir -p $working/$id/iter-$iter/step-3/bow

>&2 echo "$ROOT/tools/bow-translation-improved $dict $unigram $source $target"
$ROOT/tools/bow-translation-improved $dict $unigram $source $target
