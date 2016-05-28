#!/bin/bash

config=$1

. $config

if [ -f $working/$id/step-5/.done ]; then
  exit
fi

echo "[step-4] Starts"

mkdir -p $working/$id/step-5/

echo "[step-4] score on good GMM"

$clust/classify $working/$id/step-4/gmm-file/good.params $working/$id/step-3/feats/bad.feats > $working/$id/step-5/score.good
$clust/classify $working/$id/step-4/gmm-file/bad.params $working/$id/step-3/feats/bad.feats > $working/$id/step-5/score.bad


echo "[step-5] finished"
