#!/bin/bash

config=$1

. $config

if [ -f $working/$id/step-6/.done ]; then
  exit
fi

echo "[step-6] Starts"
mkdir -p $working/$id/step-6/
mkdir -p $working/$id/step-6/good
mkdir -p $working/$id/step-6/bad
mkdir -p $working/$id/step-6/diff

# TODO
#cat $working/$id/step-5/score.good | awk '{print $3}' | grep . > $working/$id/step-6/score.good
#cat $working/$id/step-5/score.bad | awk '{print $3}' | grep . > $working/$id/step-6/score.bad

# some sanity checks
#wc -l $working/$id/step-6/score.* $working/$id/step-3/feats/bad.feats $working/$id/step-1/bad.clean.short*

n=`wc -l $working/$id/step-6/score.good | awk '{print $1}'`
k=`echo $n * $output_percent | bc -l`

echo "[step-6] total num-sentence-pairs: $n; selecting size $k"

echo "[step-6] generating the subset that is most similar to the good data"
cat $working/$id/step-6/score.good | awk '{print $1, NR-1}' | sort -n -r -k1 > $working/$id/step-6/good/sorted

echo "[step-6] generating the subset that is most different from the bad data"
cat $working/$id/step-6/score.bad | awk '{print $1, NR-1}' | sort -n -r -k1 > $working/$id/step-6/bad/sorted

echo "[step-6] generating the subset that is most similar to the bad data"
paste $working/$id/step-6/score.good $working/$id/step-6/score.bad | awk '{print $1-$2, NR-1}' | sort -n -r -k1 > $working/$id/step-6/diff/sorted

for i in good bad diff; do
  head -n $k $working/$id/step-6/$i/sorted > $working/$id/step-6/$i/top.$k.index
  $ROOT/tools/get-lines $working/$id/step-6/$i/top.$k.index $working/$id/step-1/bad.clean.short.$input > $working/$id/step-6/$i/train.$input
  $ROOT/tools/get-lines $working/$id/step-6/$i/top.$k.index $working/$id/step-1/bad.clean.short.$output > $working/$id/step-6/$i/train.$output
done

touch $working/$id/step-6/.done

echo "[step-6] finished"
