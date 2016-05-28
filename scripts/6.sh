#!/bin/bash

config=$1

. $config

if [ -f $working/$id/step-6/.done ]; then
  exit
fi

echo "[step-6] Starts"
mkdir -p $working/$id/step-6/

cat $working/$id/step-5/score.good | awk '{print $3}' | grep . > $working/$id/step-6/score.good
cat $working/$id/step-5/score.bad | awk '{print $3}' | grep . > $working/$id/step-6/score.bad

# some sanity checks
wc -l $working/$id/step-6/score.* $working/$id/step-3/bad.feats $working/$id/step-1/bad.clean.short*



touch $working/$id/step-6/.done

echo "[step-6] finished"
