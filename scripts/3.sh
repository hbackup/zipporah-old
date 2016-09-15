#!/bin/bash

config=$1

. $config

set -x

if [ -f $working/$id/.done.3 ]; then
  exit
fi

echo "[step-3] Starts"

echo id is $id

base=$working/$id/step-3
old_feats=$working/$id/feats
feats=$base/feats

mkdir -p $base
mkdir -p $feats
mkdir -p $base/gmm-file

#for i in good bad; do
for i in bad; do
  echo "[step-3] generate sample training data for $i corpus"

  n=`wc -l $old_feats/$i.feats | awk '{print$1}'`
  k=$gmm_sample_size

  if [ $k == -1 ]; then
    k=$n
  fi

  $ROOT/tools/get-rand-index $n $k > $feats/$i.index
  $ROOT/tools/get-lines $feats/$i.index $old_feats/$i.feats > $feats/$i.feats

  echo "[step-3] clustering GMM for $i data"
  mkdir -p $base/gmm-file/$i
  $gmm_clustering_script $config $feats/$i.feats $num_gauss $base/gmm-file/$i.params $base/gmm-file/$i

done

touch $working/$id/.done.3

echo "[step-3] finished"
