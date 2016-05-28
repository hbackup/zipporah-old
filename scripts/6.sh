#!/bin/bash

config=$1

. $config

if [ -f $working/$id/step-6/.done ]; then
  exit
fi

echo "[step-6] Starts"
mkdir -p $working/$id/step-6/

# TODO
#cat $working/$id/step-5/score.good | awk '{print $3}' | grep . > $working/$id/step-6/score.good
#cat $working/$id/step-5/score.bad | awk '{print $3}' | grep . > $working/$id/step-6/score.bad

# some sanity checks
#wc -l $working/$id/step-6/score.* $working/$id/step-3/feats/bad.feats $working/$id/step-1/bad.clean.short*

echo "[step-6] generating the subset that is most similar to the good data"
cat $working/$id/step-6/score.good | awk '{print $1, NR-1}' | sort -n -r -k1 > $working/$id/step-6/sorted.good

echo "[step-6] generating the subset that is most different from the bad data"
cat $working/$id/step-6/score.bad | awk '{print $1, NR-1}' | sort -n -r -k1 > $working/$id/step-6/sorted.bad

echo "[step-6] generating the subset that is most similar to the bad data"
paste $working/$id/step-6/score.good $working/$id/step-6/score.bad | awk '{print $1-$2, NR-1}' | sort -n -r -k1 > $working/$id/step-6/sorted.diff


touch $working/$id/step-6/.done

echo "[step-6] finished"
