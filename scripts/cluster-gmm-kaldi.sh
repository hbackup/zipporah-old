#!/bin/bash

config=$1
data_file=$2
num_gauss=$3
out_param=$4
savefolder=$5

. $config

if [ $# != 5 ]; then
  echo wrong number of parameters. require 5, see $#
  echo $0 data_file num_gauss out_param optional_save_folder
  exit
fi

mkdir -p $savefolder

#m=`head -n 1 $data_file | awk '{print NF}'`
#n=`wc -l $data_file |awk '{print $1}'`
echo "fake_id [" > $savefolder/feats.ark

cat $data_file >> $savefolder/feats.ark 

echo "] " >> $savefolder/feats.ark 

nl=`wc -l $data_file | awk '{print $1}'`

$kaldi/src/gmmbin/gmm-global-init-from-feats --binary=false --num-iters=10 --num-frames=$nl --num-gauss=$num_gauss ark:$savefolder/feats.ark $savefolder/gmm.params.dgmm

#mv $savefolder/gmm.params $savefolder/gmm.params.dgmm
$kaldi/src/gmmbin/gmm-global-to-fgmm --binary=false $savefolder/gmm.params.dgmm $savefolder/gmm.params.fgmm.0
$kaldi/src/fgmmbin/fgmm-global-acc-stats --binary=false $savefolder/gmm.params.fgmm.0 ark:$savefolder/feats.ark $savefolder/acc

for i in `seq 1 $num_iters_gmm`; do
  $kaldi/src/fgmmbin/fgmm-global-est $savefolder/gmm.params.fgmm.$[$i-1] $savefolder/acc $savefolder/gmm.params.fgmm.$i
done

cp $savefolder/gmm.params.fgmm.$num_iters_gmm $out_param
