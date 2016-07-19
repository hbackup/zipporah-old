#!/bin/bash

config=$1

. $config

if [ -f $working/$id/.done.$iter.6 ]; then
  echo $working/$id/.done.$iter.6 exist
#  exit
fi

echo "[iter-$iter] [step-6] Starts"

base=$working/$id/iter-$iter/step-6
mkdir -p $base
mkdir -p $base/good
mkdir -p $base/bad

[ ! -f $base/score.good ] && cat $working/$id/iter-$iter/step-5/score.good | awk '{print $3}' | grep . > $base/score.good
[ ! -f $base/score.bad ] && cat $working/$id/iter-$iter/step-5/score.bad  | awk '{print $3}' | grep . > $base/score.bad

n=`wc -l $base/score.good | awk '{print $1}'`
k=$num_lines_selected

if [ "$k" = "" ]; then
  k=`echo "$n $output_percent" | awk '{print int($1 * $2)}'`
fi

echo "[iter-$iter] [step-6] total num-sentence-pairs: $n; selecting size $k"

echo "[iter-$iter] [step-6] generating the subset that is most similar to the good data"
[ ! -f $base/good/sorted ] && cat $base/score.good | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/good/sorted

echo "[iter-$iter] [step-6] generating the subset that is most different from the bad data"
[ ! -f $base/bad/sorted ] && cat $base/score.bad  | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/bad/sorted

for i in bad good; do
  head -n $k $base/$i/sorted | awk '{print $2}' > $base/$i/top.$k.index
  $ROOT/tools/get-lines $base/$i/top.$k.index $working/$id/iter-1/step-1/bad.clean.short.$input_lang  > $base/$i/train$num_lines_selected.$input_lang
  $ROOT/tools/get-lines $base/$i/top.$k.index $working/$id/iter-1/step-1/bad.clean.short.$output_lang > $base/$i/train$num_lines_selected.$output_lang
done

touch $working/$id/.done.$iter.6

echo "[iter-$iter] [step-6] finished"
