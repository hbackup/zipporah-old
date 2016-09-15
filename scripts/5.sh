#!/bin/bash

config=$1

. $config

if [ -f $working/$id/.done.5 ]; then
  echo $working/$id/.done.5 exist
#  exit
fi

echo "[step-5] Starts"

base=$working/$id/step-5
mkdir -p $base
#mkdir -p $base/good
mkdir -p $base/bad

#[ ! -f $base/score.good ] && cat $working/$id/step-5/score.good > $base/score.good
[ ! -f $base/score.bad ] && cat $working/$id/step-4/score.bad  > $base/score.bad


#echo "[step-5] generating the subset that is most similar to the good data"
#[ ! -f $base/good/sorted ] && cat $base/score.good | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/good/sorted

[ ! -f $base/bad/sorted ] && cat $base/score.bad  | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/bad/sorted

for k in $output_words; do
#for i in bad good; do
  echo "[step-5] generating the subset that is most concentrated in the bad data"
  for i in bad; do
    cat $base/$i/sorted | awk '{print $2}' > $base/$i/index

    [ ! -f $working/$id/step-1/bad.clean.short.pasted ] && \
      paste $working/$id/step-1/bad.clean.short.$input_lang $working/$id/step-1/bad.clean.short.$output_lang > $working/$id/step-1/bad.clean.short.pasted

    $ROOT/tools/get-lines-by-words $base/$i/index $working/$id/step-1/bad.clean.short.pasted $k > $base/$i/train$k.pasted

    cat $base/$i/train$k.pasted | awk -F '\t' '{print $1}' > $base/$i/train.$k.$input_lang
    cat $base/$i/train$k.pasted | awk -F '\t' '{print $2}' > $base/$i/train.$k.$output_lang
  done

  echo "[step-5] generating a random subset for comparison"

  mkdir -p $base/rand/
  cat $base/bad/index | shuf > $base/rand/index
  for i in rand; do
    $ROOT/tools/get-lines-by-words $base/$i/index $working/$id/step-1/bad.clean.short.pasted $k > $base/$i/train$k.pasted

    cat $base/$i/train$k.pasted | awk -F '\t' '{print $1}' > $base/$i/train.$k.$input_lang
    cat $base/$i/train$k.pasted | awk -F '\t' '{print $2}' > $base/$i/train.$k.$output_lang
  done

  rm -f $working/$id/train.??
  rm -f $working/$id/rand.??

done

for k in $output_words; do
  ln -s $base/bad/train.$k.$input_lang $working/$id/train.$k.$input_lang
  ln -s $base/bad/train.$k.$output_lang $working/$id/train.$k.$output_lang

  ln -s $base/rand/train.$k.$input_lang $working/$id/rand.$k.$input_lang
  ln -s $base/rand/train.$k.$output_lang $working/$id/rand.$k.$output_lang
done

touch $working/$id/.done.5

echo "[step-5] finished"
