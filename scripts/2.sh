#!/bin/bash

config=$1

. $config

if [ ! -f $e2f ] || [ ! -f $f2e ]; then
  echo -n "[step-2] starts," && grep "^#2:" steps.info | awk -F ':' '{print $2}' 

  mkdir -p $working/$id/step-2
  mkdir -p $working/$id/step-2/MT

  cat $ROOT/scripts/template.config | sed "s=CORPUS_STEM=$working/$id/step-1/ref.clean.short=g" | \
        sed "s=INPUT=$input=g" | sed "s=OUTPUT=$output=g" | sed "s=WORKINGDIR=$working/$id/step-2/MT=g" > $working/$id/mt.config

  while [ ! -f $working/$id/step-1/ref.clean.short.$input ] || [ ! -f $working/$id/step-1/ref.clean.short.$output ]; do
    echo "[step-2] waiting for ref corpus to finish processing"
    sleep 5m;
  done

  ~/mosesdecoder/scripts/ems/experiment.perl -config $working/$id/mt.config -cluster -exec > $working/$id/LOGs/2.mt.log

else
  echo "[step-2] lex table already provided. Using $e2f and $f2e"
fi

echo "[step-2] finished."
