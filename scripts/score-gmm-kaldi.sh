#!/bin/bash

config=$1
model=$2
data=$3
tmpfolder=$4

mkdir -p $tmpfolder

. $config

echo "fake_id [ " > $tmpfolder/feats.ark
cat $data >> $tmpfolder/feats.ark
echo "]" >> $tmpfolder/feats.ark

#echo "$kaldi/src/gmmbin/fgmm-global-get-frame-likes $model ark:$tmpfolder/feats.ark ark,t:-"
$kaldi/src/fgmmbin/fgmm-global-get-frame-likes $model ark:$tmpfolder/feats.ark "ark,t:-" | sed 's= =\n=g' | tee $tmpfolder/tmp | grep [0-9] 
