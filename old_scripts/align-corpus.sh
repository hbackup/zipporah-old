#!/bin/bash

config=$1
intext=$2
outtext=$3
output=$4
tmpfolder=$5
nj=$6

. $config

mkdir -p $tmpfolder

paste $intext $outtext > $tmpfolder/pasted

split -a 6 -d -n l/$nj $tmpfolder/pasted $tmpfolder/s.

n=$[$nj]
for i in `seq -w $[$nj-1] -1 0`; do
  while [ ! -f $tmpfolder/s.$i ]; do
    i=0$i
  done
  mv $tmpfolder/s.$i $tmpfolder/s.$n

  cat $tmpfolder/s.$n | awk -F '\t' '{print $1}' > $tmpfolder/s.in.$n
  cat $tmpfolder/s.$n | awk -F '\t' '{print $2}' > $tmpfolder/s.out.$n

  n=$[$n-1]
done

$ROOT/scripts/queue.pl -l "hostname=b*" JOB=1:$nj $tmpfolder/align.log.JOB $aligner -text $dict \
   $tmpfolder/s.in.JOB $tmpfolder/s.out.JOB \> $tmpfolder/out.JOB

if [ -f $output ]; then
  rm $output
fi

for i in `seq 1 $[$nj]`; do
  cat $tmpfolder/out.$i >> $output
done

echo Aligning job done
