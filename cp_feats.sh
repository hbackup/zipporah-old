#!/bin/bash

working=$1
from=$2
to=$3

cd $working

if [ -d $to ]; then
  echo $working/$to already exists
  exit 1
fi

mkdir $to
mkdir $to/iter-1

cd $to/iter-1

ln -s ../../$from/iter-1/step-1
ln -s ../../$from/iter-1/step-2
ln -s ../../$from/iter-1/step-3
