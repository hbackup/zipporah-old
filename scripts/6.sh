#!/bin/bash

config=$1

. $config

if [ -f $working/$id/step-6/.done.$iter ]; then
  exit
fi

echo "[iter-$iter] [step-6] Starts"
mkdir -p $working/$id/step-6/
mkdir -p $working/$id/step-6/iter-$iter
mkdir -p $working/$id/step-6/iter-$iter/good
mkdir -p $working/$id/step-6/iter-$iter/bad
mkdir -p $working/$id/step-6/iter-$iter/diff

cat $working/$id/step-5/iter-$iter/score.good | awk '{print $3}' | grep . > $working/$id/step-6/iter-$iter/score.good
cat $working/$id/step-5/iter-$iter/score.bad | awk '{print $3}' | grep . > $working/$id/step-6/iter-$iter/score.bad

n=`wc -l $working/$id/step-6/iter-$iter/score.good | awk '{print $1}'`
k=`echo "$n $output_percent" | awk '{print int($1 * $2)}'`

echo "[iter-$iter] [step-6] total num-sentence-pairs: $n; selecting size $k"

echo "[iter-$iter] [step-6] generating the subset that is most similar to the good data"
cat $working/$id/step-6/iter-$iter/score.good | awk '{print $1, NR-1}' | sort -n -r -k1 > $working/$id/step-6/iter-$iter/good/sorted

echo "[iter-$iter] [step-6] generating the subset that is most different from the bad data"
cat $working/$id/step-6/iter-$iter/score.bad | awk '{print $1, NR-1}' | sort -n -r -k1 > $working/$id/step-6/iter-$iter/bad/sorted

echo "[iter-$iter] [step-6] generating the subset that is most similar to the bad data"
paste $working/$id/step-6/iter-$iter/score.good $working/$id/step-6/iter-$iter/score.bad | awk '{print $1-$2, NR-1}' | sort -n -r -k1 > $working/$id/step-6/iter-$iter/diff/sorted

for i in good bad diff; do
  head -n $k $working/$id/step-6/iter-$iter/$i/sorted | awk '{print $2}' > $working/$id/step-6/iter-$iter/$i/top.$k.index
  $ROOT/tools/get-lines $working/$id/step-6/iter-$iter/$i/top.$k.index $working/$id/step-1/iter-$iter/bad.clean.short.$input_lang > $working/$id/step-6/iter-$iter/$i/train.$input_lang
  $ROOT/tools/get-lines $working/$id/step-6/iter-$iter/$i/top.$k.index $working/$id/step-1/iter-$iter/bad.clean.short.$output_lang > $working/$id/step-6/iter-$iter/$i/train.$output_lang
done

touch $working/$id/step-6/.done.$iter

echo "[iter-$iter] [step-6] finished"
