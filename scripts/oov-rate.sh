#!/bin/bash

textfile=$1
dictfile=$2
outputfile=$3

cat $textfile | awk -v f=$dictfile 'BEGIN{while((getline<f)>0) d[$1]=1}  {sum=0;oov=0;for(i=1;i<=NF;i++) {sum+=1; if(d[$i]!=1) oov+=1} print oov/sum}' > $outputfile
