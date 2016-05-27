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

  $ROOT/scripts/tag-pos.sh $config $train.$input $working/$id/step-3/tagged/$train.$input

  exit
  $ROOT/scripts/tag-pos.sh $config $train.$output $working/$id/step-3/tagged/$train.$output

  $ROOT/scripts/tag-pos.sh $config $test.$input $working/$id/step-3/tagged/$test.$input
  $ROOT/scripts/tag-pos.sh $config $test.$output $working/$id/step-3/tagged/$test.$output



fi
