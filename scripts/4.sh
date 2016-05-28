#!/bin/bash

config=$1

if [ -f $working/$id/step-4/.done ]; then
  exit
fi

echo "[step-4] starts"

mkdir -p $working/$id/step-4/
mkdir -p $working/$id/step-4/gmm-file


feats=$working/$id/step-3/feats

$ROOT/scripts/cluster-gmm.sh $config $feats/good.feats $num_gauss $working/$id/step-4/gmm-file/params $working/$id/step-4/gmm-file

touch $working/$id/step-4/.done

echo "[step-4] finished"
