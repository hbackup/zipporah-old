#!/bin/bash

config=$1

. $config

if [ -f $working/$id/.done.$iter.4 ]; then
  exit
fi

echo "[iter-$iter] [step-4] Starts"

mkdir -p $working/$id/step-4/
mkdir -p $working/$id/step-4/feats
mkdir -p $working/$id/step-4/feats/iter-$iter
mkdir -p $working/$id/step-4/gmm-file
mkdir -p $working/$id/step-4/gmm-file/iter-$iter

feats=$working/$id/step-3/feats/iter-$iter

for i in good bad; do
  echo "[iter-$iter] [step-4] generate sample training data for $i corpus"
  n=`wc -l $feats/$i.feats | awk '{print$1}'`
  k=$gmm_sample_size

  $ROOT/tools/get-rand-index $n $k > $working/$id/step-4/feats/iter-$iter/$i.index
  $ROOT/tools/get-lines $working/$id/step-4/feats/iter-$iter/$i.index $feats/good.feats > $working/$id/step-4/feats/iter-$iter/$i.feats

  echo "[iter-$iter] [step-4] clustering GMM for $i data"
  mkdir -p $working/$id/step-4/gmm-file/iter-$iter/$i
  $ROOT/scripts/cluster-gmm.sh $config $working/$id/step-4/feats/iter-$iter/$i.feats $num_gauss $working/$id/step-4/gmm-file/iter-$iter/$i.params $working/$id/step-4/gmm-file/iter-$iter/$i

done

touch $working/$id/.done.$iter.4

echo "[iter-$iter] [step-4] finished"
