#!/bin/bash

if [ $# -ne 5 ]; then
  echo $0 command input-file output-file num-jobs tmp-folder
  exit 1
fi

command=$1
input=$2
output=$3
nj=$4
tmpfolder=$5

mkdir -p $tmpfolder
split -d -n l/$nj $input $tmpfolder/s.

n=$[$nj]
for i in `seq -w $[$nj-1] -1 0`; do
  while [ ! -f $tmpfolder/s.$i ]; do
    i=0$i
  done
  mv $tmpfolder/s.$i $tmpfolder/s.$n
  n=$[$n-1]
done

$ROOT/scripts/queue.pl JOB=1:$nj $tmpfolder/log.JOB $command $tmpfolder/s.JOB $tmpfolder/out.JOB

for i in `seq 1 $[$nj]`; do
  cat $tmpfolder/out.$i >> $output
done

n1=`wc -l $input | awk '{print $1}'`
n2=`wc -l $output | awk '{print $1}'`

if [ $n1 -ne $n2 ]; then
  echo Warning: input and output have different number of lines
  exit -1
fi
