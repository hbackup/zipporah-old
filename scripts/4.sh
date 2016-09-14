#!/bin/bash

config=$1

set -e

. $config

if [ -f $working/$id/.done.4 ]; then
  exit
fi

echo "[step-4] Starts"

base=$working/$id/step-4
mkdir -p $base

echo "[step-4] score on good GMM"

echo "[step-4] the next lines should be equal"

#$gmm_scoring_script $config $working/$id/step-4/gmm-file/good.params $working/$id/feats/bad.feats $working/$id/feats/good.tmp | tee $base/score.good | wc -l
wc -l $working/$id/feats/bad.feats

$gmm_scoring_script $config $working/$id/step-3/gmm-file/bad.params $working/$id/feats/bad.feats $working/$id/feats/bad.tmp | tee $base/score.bad | wc -l

touch $working/$id/.done.4

echo "[step-4] finished"
