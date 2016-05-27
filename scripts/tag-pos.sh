#!/bin/bash

config=$1
stem=$2
lang=$3
output=$4

file=`basename $stem`

. $config

model=
case "$lang" in
  en) model=$tagger/model/wsj-0-18-left3words-nodistsim.tagger
  ;;
  fr) model=$tagger/model/french.tagger
  ;;
  de) model=$tagger/model/german-fast.tagger
  ;;
esac

if [ "$lang" != "de" ]; then
  $ROOT/scripts/run-in-parallel.sh "$tagger/stanford-postagger.sh $model" $stem.$lang $output $pos_jobs $working/$id/step-3/tagged/tmp/$file.$lang/
else
  # need to change file encoding to avoid some issue
  iconv -c -f utf-8 -t ISO-8859-1 $stem.de > $working/$id/step-3/$file.de.iso
  $ROOT/scripts/run-in-parallel.sh "$tagger/stanford-postagger.sh $model" $working/$id/step-3/$file.de.iso $output $pos_jobs $working/$id/step-3/tagged/tmp/$file.$lang/
fi
