#!/bin/bash

config=$1

. $config

if [ ! -f $e2f ] || [ ! -f $f2e ]; then
  echo -n "[iter-$iter] [step-2] starts," && grep "^#2:" steps.info | awk -F ':' '{print $2}' 

  mkdir -p $working/$id/step-2
  mkdir -p $working/$id/step-2/MT
  mkdir -p $working/$id/step-2/MT/iter-$iter

  cat $ROOT/scripts/template.config | sed "s=CORPUS_STEM=$working/$id/step-1/iter-$iter/good.clean.short=g" | \
        sed "s=INPUT=$input_lang=g" | sed "s=OUTPUT=$output_lang=g" | sed "s=WORKINGDIR=$working/$id/step-2/MT/iter-$iter=g" > $working/$id/mt.config.iter-$iter

  ~/mosesdecoder/scripts/ems/experiment.perl -config $working/$id/mt.config.iter-$iter -cluster -exec > $working/$id/LOGs/2.$iter.mt.log

else
  echo "[iter-$iter] [step-2] lex table already provided. Using $e2f and $f2e"
fi

echo "[iter-$iter] [step-2] finished."
