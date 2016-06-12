#!/bin/bash

input=$1
lang=$2
tmpfolder=$3

cat $input | awk '{print "LINE_SPECIAL_SYM"NR": "$0}' > $tmpfolder/pasted

cat $tmpfolder/pasted | ./cmd/tree-tagger-english

