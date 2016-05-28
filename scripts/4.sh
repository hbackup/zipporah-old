#!/bin/bash

config=$1

. $config

if [ -f $working/$id/step-4/.done ]; then
  exit
fi

echo "[step-4] Starts"

mkdir -p $working/$id/step-4/
mkdir -p $working/$id/step-4/feats
mkdir -p $working/$id/step-4/gmm-file

feats=$working/$id/step-3/feats

for i in good bad; do
  echo "[step-4] generate sample training data for $i corpus"
  n=`wc -l $feats/$i.feats | awk '{print$1}'`
  k=$gmm_sample_size

  $ROOT/tools/get-rand-index $n $k > $working/$id/step-4/feats/$i.index
  $ROOT/tools/get-lines $working/$id/step-4/feats/$i.index $feats/good.feats > $working/$id/step-4/feats/$i.feats

  echo "[step-4] clustering GMM for $i data"
  $ROOT/scripts/cluster-gmm.sh $config $working/$id/step-4/feats/$i.feats $num_gauss $working/$id/step-4/gmm-file/params $working/$id/step-4/gmm-file

done

touch $working/$id/step-4/.done

echo "[step-4] finished"
