#!/bin/bash

config=$1
input=$2
lang=$3

case "$lang" in
  en) lang=english
  ;;
  fr) lang=french
  ;;
  de) lang=german
  ;;
esac

name=`basename $input`
cat $input | awk '{print "LINE_SPECIAL_SYM"NR": "$0}' > $working/$id/$name.pasted

cat $working/$id/$name.pasted | $ROOT/external/cmd/tree-tagger-$lang

