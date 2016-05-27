#!/bin/bash

config=$1
lang=$2
raw=$3
clean=$4

file=`basename $raw`

echo convert raw corpus to tokenized, true-cased, clean text

if [ ! $# -eq 4 ]; then
  echo $0 config lang raw clean
  exit 1
fi

. $config

set -v

tmp=$working/$id/step-1/tmp
mkdir -p $tmp

$moses/scripts/tokenizer/tokenizer.perl -l $lang \
    -threads 16                                          \
    < $raw                                               \
    > $tmp/${file}.tokenized

if [ ! -f ~/corpus/truecase-model.$lang ]; then
$moses/scripts/recaser/train-truecaser.perl \
    --model $tmp/truecase-model.$lang --corpus     \
    $tmp/${file}.tokenized

fi

$moses/scripts/recaser/truecase.perl \
    --model $tmp/truecase-model.$lang    \
    < $tmp/${file}.tokenized                 \
    > $clean
