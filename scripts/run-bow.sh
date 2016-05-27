#!/bin/bash

dict=$1
source=$2
target=$3

set -v

cat $dict | awk '$3>0.1{print}' > $dict.short

#~/data_selection/tools/bow-translation $dict.short source

cat $source | ~/data_selection/tools/bow-translation $dict.short - | python tools/unigram-similarity-soft.py - $target

