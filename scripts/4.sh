#!/bin/bash

config=$1
. $config

oldbase=$working/$id/step-3/
base=$working/$id/step-4/

mkdir -p $base

echo merging with ngram-weight = $ngram_weight
paste $oldbase/bad.bow.* $oldbase/bad.ppl.?? | \
        awk -v w=$ngram_weight '{print $1+$2+w*($3+$4)}' > $base/scores

cat $base/scores | awk '{print NR-1, $1}' | sort -k2n | tee $base/NR.scores.sorted | \
      awk '{print $1}' > $base/sorted.index


for k in $output_words; do
  echo "[step-4] doing data selection based on the scores, selecting $k words"

  i=good
  mkdir -p $base/$i
  [ ! -f $working/$id/step-1/bad.clean.short.pasted ] && \
    paste $working/$id/step-1/bad.clean.short.$input_lang $working/$id/step-1/bad.clean.short.$output_lang > $working/$id/step-1/bad.clean.short.pasted

  $ROOT/tools/get-lines-by-words $base/sorted.index $working/$id/step-1/bad.clean.short.pasted $k > $base/$i/train$k.pasted

  cat $base/$i/train$k.pasted | awk -F '\t' '{print $1}' > $base/$i/train.$k.$input_lang
  cat $base/$i/train$k.pasted | awk -F '\t' '{print $2}' > $base/$i/train.$k.$output_lang

  echo "[step-4] generating a random subset for comparison"

  mkdir -p $base/rand/
  cat $base/sorted.index | shuf > $base/rand/index
  for i in rand; do
    $ROOT/tools/get-lines-by-words $base/$i/index $working/$id/step-1/bad.clean.short.pasted $k > $base/$i/train$k.pasted

    cat $base/$i/train$k.pasted | awk -F '\t' '{print $1}' > $base/$i/train.$k.$input_lang
    cat $base/$i/train$k.pasted | awk -F '\t' '{print $2}' > $base/$i/train.$k.$output_lang
  done
done
