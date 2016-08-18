#!/bin/bash

config=$1

set -e

. $config

if [ -f $working/$id/.done.$iter.5 ]; then
  exit
fi

echo "[iter-$iter] [step-5] Starts"

base=$working/$id/iter-$iter/step-5
mkdir -p $base

echo "[iter-$iter] [step-5] score on good GMM"

echo "[iter-$iter] [step-5] the next lines should be equal"

#$gmm_scoring_script $config $working/$id/iter-$iter/step-4/gmm-file/good.params $working/$id/iter-$iter/feats/bad.feats $working/$id/iter-$iter/feats/good.tmp | tee $base/score.good | wc -l
wc -l $working/$id/iter-$iter/feats/bad.feats

$gmm_scoring_script $config $working/$id/iter-$iter/step-4/gmm-file/bad.params $working/$id/iter-$iter/feats/bad.feats $working/$id/iter-$iter/feats/bad.tmp | tee $base/score.bad | wc -l

touch $working/$id/.done.$iter.5

echo "[iter-$iter] [step-5] finished"
