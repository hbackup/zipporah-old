#!/bin/bash

config=$1

. $config

train=$working/$id/step-1/good.clean.short
test=$working/$id/step-1/bad.clean.short

echo "[step-3] Start"

mkdir -p $working/$id/step-3
mkdir -p $working/$id/step-3/tagged/

if [ $pos_feat = true ]; then
  echo "[step-3] running the Stanford tagger to generate PoS features"

# TODO; restore this
#  $ROOT/scripts/tag-pos.sh $config $train $input $working/$id/step-3/tagged/good.$input
#  $ROOT/scripts/tag-pos.sh $config $train $output $working/$id/step-3/tagged/good.$output
#
#  $ROOT/scripts/tag-pos.sh $config $test $input $working/$id/step-3/tagged/bad.$input
#  $ROOT/scripts/tag-pos.sh $config $test $output $working/$id/step-3/tagged/bad.$output


  cat $working/$id/step-3/tagged/good.$input | head -n $pos_sample > $working/$id/step-3/tagged/good.sample.$input
  cat $working/$id/step-3/tagged/good.$output | head -n $pos_sample > $working/$id/step-3/tagged/good.sample.$output

  $ROOT/scripts/generate-pos-features.sh $config $working/$id/step-3/tagged/good.sample $working/$id/step-3/tagged/good
  $ROOT/scripts/generate-pos-features.sh $config $working/$id/step-3/tagged/good.sample $working/$id/step-3/tagged/bad

fi

