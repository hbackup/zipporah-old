#!/bin/bash

config=$1

. $config

if [ "$url_bad" == "" ]; then
  echo No url files found. Not doing step-6
  exit 1
fi

echo "[step-6] starts"

mkdir -p $working/$id/step-6

cat $working/$id/step-1/lines-retained | awk '{print $1-1}' > $working/$id/step-6/lines-retained-0

$ROOT/tools/get-lines $working/$id/step-6/lines-retained-0 $url_bad > $working/$id/step-6/urls

for i in good bad; do
  mkdir -p $working/$id/step-6/$i

  tac $working/$id/step-5/$i/index > $working/$id/step-6/$i/reversed.index

  for k in $output_words; do
    head -n 1000000 $working/$id/step-6/$i/reversed.index > $working/$id/step-6/$i/r.index.1000000
    $ROOT/tools/get-lines $working/$id/step-6/$i/r.index.1000000 $url_bad | uniq | sort -u > $working/$id/step-6/$i/bad_urls

    $ROOT/tools/select-by-url $working/$id/step-6/$i/bad_urls \
      $working/$id/step-1/bad.clean.short.pasted $working/$id/step-5/score.$i \
      $working/$id/step-6/urls \
      $working/$id/step-6/$i/clean.pasted $working/$id/step-6/$i/score

    cat $working/$id/step-6/$i/score | awk '{print NR-1,$1}' \
     | sort -k2 -nr | awk '{print $1}' > $working/$id/step-6/$i/clean.index

    $ROOT/tools/get-lines-by-words $working/$id/step-6/$i/clean.index \
      $working/$id/step-6/$i/clean.pasted $k > $working/$id/step-6/$i/clean.pasted.$k

    cat $working/$id/step-6/$i/clean.pasted.$k |\
      awk -F '\t' '{print $1}' > $working/$id/step-6/$i/clean.$k.$input_lang
    cat $working/$id/step-6/$i/clean.pasted.$k |\
      awk -F '\t' '{print $2}' > $working/$id/step-6/$i/clean.$k.$output_lang
  done
done
