#!/bin/bash

config=$1

. $config

if [ -f $working/$id/.done.$iter.6 ]; then
  exit
fi

echo "[iter-$iter] [step-6] Starts"

base=$working/$id/iter-$iter/step-6
mkdir -p $base
mkdir -p $base/good
mkdir -p $base/bad

cat $working/$id/step-5/iter-$iter/score.good | awk '{print $3}' | grep . > $base/score.good
cat $working/$id/step-5/iter-$iter/score.bad  | awk '{print $3}' | grep . > $base/score.bad

n=`wc -l $working/$id/iter-$iter/step-6/score.good | awk '{print $1}'`
k=`echo "$n $output_percent" | awk '{print int($1 * $2)}'`

echo "[iter-$iter] [step-6] total num-sentence-pairs: $n; selecting size $k"

echo "[iter-$iter] [step-6] generating the subset that is most similar to the good data"
cat $base/score.good | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/good/sorted

echo "[iter-$iter] [step-6] generating the subset that is most different from the bad data"
cat $base/score.bad  | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/bad/sorted

for i in good bad; do
  head -n $k $base/$i/sorted | awk '{print $2}' > $base/$i/top.$k.index
  $ROOT/tools/get-lines $base/$i/top.$k.index $working/$id/iter-1/step-1/bad.clean.short.$input_lang  > $base/$i/train.$input_lang
  $ROOT/tools/get-lines $base/$i/top.$k.index $working/$id/iter-1/step-1/bad.clean.short.$output_lang > $base/$i/train.$output_lang
done

touch $working/$id/.done.$iter.6

echo "[iter-$iter] [step-6] finished"
