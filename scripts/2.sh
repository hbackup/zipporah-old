#!/bin/bash

config=$1

. $config

oldbase=$working/$id/step-1
base=$working/$id/step-2

set -x


mkdir -p $base

rm -r -f $base/tmp.align

if [ "$f2e$e2f" == "" ]; then
  if [ "$alignment" == "" ]; then
    alignment=$base/alignment
    $ROOT/scripts/align-corpus.sh $config $aligner $oldbase/good.clean.short.$input_lang $oldbase/good.clean.short.$output_lang $alignment $base/tmp.align
  fi
  $ROOT/tools/align-to-dict $dict_count_thresh $oldbase/good.clean.short.$input_lang $oldbase/good.clean.short.$output_lang $alignment $base/dict.$input_lang-$output_lang $base/dict.$output_lang-$input_lang
  for i in $base/dict.$input_lang-$output_lang $base/dict.$output_lang-$input_lang; do
    mv $i $i.with.num
    cat $i.with.num | grep [a-zA-Z] | grep -v "^[!0-9;%&()‘’+–,?./:\-]" > $i
  done
else
  cp $f2e $base/dict.$input_lang-$output_lang
  cp $e2f $base/dict.$output_lang-$input_lang
fi
#$moses/tools/fast_align -i $base/good.pasted -d -o -v > $base/fast-align.1

