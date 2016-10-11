#!/bin/bash

config=$1

. $config

if [ "$url_bad" == "" ]; then
  echo No url files found. Not doing step-5
  exit 1
fi

echo "[step-5] starts"

mkdir -p $working/$id/step-5

cat $working/$id/step-1/lines-retained | awk '{print $1-1}' > $working/$id/step-5/lines-retained-0

$ROOT/tools/get-lines $working/$id/step-5/lines-retained-0 $url_bad > $working/$id/step-5/urls

#for i in good bad; do
#i=good

mkdir -p $working/$id/step-5/$i

#tac $working/$id/step-4/sorted.index > $working/$id/step-5/reversed.index

for k in $output_words; do
  tail -n 1 $working/$id/step-4/sorted.index > $working/$id/step-5/$i/r.index.1000000

  $ROOT/tools/get-lines $working/$id/step-5/$i/r.index.1000000 $url_bad | uniq | sort -u > $working/$id/step-5/bad_urls

  $ROOT/tools/select-by-url $working/$id/step-5/bad_urls \
    $working/$id/step-1/bad.clean.short.pasted $working/$id/step-4/scores \
    $working/$id/step-5/urls \
    $working/$id/step-5/clean.pasted $working/$id/step-5/score

  cat $working/$id/step-5/score | awk '{print NR-1,$1}' \
   | sort -k2 -nr | awk '{print $1}' > $working/$id/step-5/clean.index

  $ROOT/tools/get-lines-by-words $working/$id/step-5/clean.index \
    $working/$id/step-5/clean.pasted $k > $working/$id/step-5/clean.pasted.$k

  cat $working/$id/step-5/clean.pasted.$k |\
    awk -F '\t' '{print $1}' > $working/$id/step-5/clean.$k.$input_lang
  cat $working/$id/step-5/clean.pasted.$k |\
    awk -F '\t' '{print $2}' > $working/$id/step-5/clean.$k.$output_lang
done
#done
