#!/bin/bash

config=$1
lang=$2  # en or fr for now
raw=$3
clean=$4

echo convert raw corpus to tokenized, true-cased, clean text

if [ ! $# -eq 3 ]; then
  echo $0 lang raw clean
  exit 1
fi

set -v

mkdir -p /tmp/hxu/raw_tmp/

~/tools/mosesdecoder/scripts/tokenizer/tokenizer.perl -l $lang \
    -threads 16                                          \
    < $raw                                               \
    > /tmp/hxu/raw_tmp/${raw}.tokenized

if [ ! -f ~/corpus/truecase-model.$lang ]; then
~/tools/mosesdecoder/scripts/recaser/train-truecaser.perl \
    --model /tmp/hxu/raw_tmp/truecase-model.$lang --corpus     \
    /tmp/hxu/raw_tmp/${raw}.tokenized

fi

~/tools/mosesdecoder/scripts/recaser/truecase.perl \
    --model /tmp/hxu/raw_tmp/truecase-model.$lang    \
    < /tmp/hxu/raw_tmp/${raw}.tokenized                 \
    > $clean
