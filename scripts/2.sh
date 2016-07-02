#!/bin/bash

config=$1

. $config

if [ ! -f $e2f ] || [ ! -f $f2e ]; then
  echo -n "[iter-$iter] [step-2] starts," && grep "^#2:" steps.info | awk -F ':' '{print $2}' 

  mkdir -p $working/$id/iter-$iter
  base=$working/$id/iter-$iter/step-2
  mkdir -p $base
  mkdir -p $base/MT

  cat $ROOT/scripts/template.config | sed "s=CORPUS_STEM=$working/$id/iter-$iter/step-1/good.clean.short=g" | \
        sed "s=INPUT=$input_lang=g" | sed "s=OUTPUT=$output_lang=g" | sed "s=WORKINGDIR=$base/MT=g" > $working/$id/mt.config.iter-$iter

  ~/mosesdecoder/scripts/ems/experiment.perl -config $working/$id/mt.config.iter-$iter -cluster -exec > $working/$id/LOGs/2.$iter.mt.log &

  while [ ! -f $e2f ] || [ ! -f $f2e ]; do
    sleep 10m
  done

else
  echo "[iter-$iter] [step-2] lex table already provided. Using $e2f and $f2e"
fi

echo "[iter-$iter] [step-2] finished."
