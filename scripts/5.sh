#!/bin/bash

config=$1

. $config

if [ -f $working/$id/.done.$iter.5 ]; then
  exit
fi

echo "[iter-$iter] [step-5] Starts"

base=$working/$id/iter-$iter/step-5
mkdir -p $base

echo "[iter-$iter] [step-5] score on good GMM"

$clust/classify $working/$id/iter-$iter/step-4/gmm-file/good.params $working/$id/iter-$iter/step-3/feats/bad.feats > $base/score.good
$clust/classify $working/$id/iter-$iter/step-4/gmm-file/bad.params  $working/$id/iter-$iter/step-3/feats/bad.feats > $base/score.bad

touch $working/$id/.done.$iter.5

echo "[iter-$iter] [step-5] finished"
