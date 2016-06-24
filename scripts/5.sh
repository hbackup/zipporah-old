#!/bin/bash

config=$1

. $config

if [ -f $working/$id/step-5/.done.$iter ]; then
  exit
fi

echo "[step-5] Starts"

mkdir -p $working/$id/step-5/
mkdir -p $working/$id/step-5/iter-$iter

echo "[step-5] score on good GMM"

$clust/classify $working/$id/step-4/gmm-file/iter-$iter/good.params $working/$id/step-3/feats/iter-$iter/bad.feats > $working/$id/step-5/iter-$iter/score.good
$clust/classify $working/$id/step-4/gmm-file/iter-$iter/bad.params $working/$id/step-3/feats/iter-$iter/bad.feats > $working/$id/step-5/iter-$iter/score.bad

touch $working/$id/step-5/.done.$iter

echo "[step-5] finished"
