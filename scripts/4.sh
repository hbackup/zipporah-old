#!/bin/bash

config=$1

if [ -f $working/$id/step-4/.done ]; then
  exit
fi

echo "[step-4] starts"

mkdir -p $working/$id/step-4/
mkdir -p $working/$id/step-4/feats
mkdir -p $working/$id/step-4/gmm-file

feats=$working/$id/step-3/feats

for i in good bad; do
  n=`wc -l $feats/$i.feats | awk '{print$1}'`
  k=$gmm_sample_size

  $ROOT/tools/get-rand-index $n $k > $working/$id/step-4/feats/$i.index
  $ROOT/tools/get-lines $working/$id/step-4/feats/$i.index $feats/good.feats > $working/$id/step-4/feats/$i.feats

  $ROOT/scripts/cluster-gmm.sh $config $feats/good.feats $num_gauss $working/$id/step-4/gmm-file/params $working/$id/step-4/gmm-file

done

touch $working/$id/step-4/.done

echo "[step-4] finished"
