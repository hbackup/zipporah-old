#!/bin/bash

config=$1
stem=$2
lang=$3
outputfile=$4

file=`basename $stem`

. $config

model=
case "$lang" in
  en) model=$tagger/models/wsj-0-18-left3words-nodistsim.tagger
  ;;
  fr) model=$tagger/models/french.tagger
  ;;
  de) model=$tagger/models/german-fast.tagger
  ;;
esac

if [ "$lang" != "de" ]; then
  $ROOT/scripts/run-in-parallel.sh "$tagger/stanford-postagger.sh $model" $stem.$lang $outputfile $pos_jobs $working/$id/step-3/tagged/tmp/$file.$lang/ $ROOT
else
  # need to change file encoding to avoid some issue
  iconv -c -f utf-8 -t ISO-8859-1 $stem.de | sed "s=^ *$=ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ=g" > $working/$id/step-3/$file.de.iso
  $ROOT/scripts/run-in-parallel.sh "$tagger/stanford-postagger.sh $model" $working/$id/step-3/$file.de.iso $outputfile $pos_jobs $working/$id/step-3/tagged/tmp/$file.$lang/ $ROOT
fi
