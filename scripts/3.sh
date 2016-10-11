#!/bin/bash

config=$1
. $config

train=$working/$id/step-1/good.clean.short
test=$working/$id/step-1/bad.clean.short
oldbase=$working/$id/step-2/
base=$working/$id/step-3/

f2e=$oldbase/dict.$input_lang-$output_lang
e2f=$oldbase/dict.$output_lang-$input_lang

set -x


mkdir -p $base

#if [ ! -f $base/bad.bow.$input_lang-$output_lang ]; then
if [ true ]; then
  echo getting BoW features
  echo using dictionary $e2f and $f2e
  
  n=$bow_jobs
  tmpfolder=$base/tmp.bow/
  mkdir -p $tmpfolder

  true && (
  rm $tmpfolder/ -f -r
  mkdir -p $tmpfolder

  paste $test.$input_lang $test.$output_lang > $tmpfolder/pasted
  split -a 3 -d -n l/$n $tmpfolder/pasted $tmpfolder/pasted.s.

#  split -a 3 -d -n l/$n $test.$input_lang $tmpfolder/s.in.
#  split -a 3 -d -n l/$n $test.$output_lang $tmpfolder/s.out.
  
  for i in `seq -w $[$n-1] -1 0`; do
    while [ ! -f $tmpfolder/pasted.s.$i ]; do
      i=0$i
    done
    cat $tmpfolder/pasted.s.$i | awk -F '\t' '{print $1}' > $tmpfolder/s.in.$n
    cat $tmpfolder/pasted.s.$i | awk -F '\t' '{print $2}' > $tmpfolder/s.out.$n
#    mv $tmpfolder/s.in.$i $tmpfolder/s.in.$n
#    mv $tmpfolder/s.out.$i $tmpfolder/s.out.$n
    n=$[$n-1]
  done

  $ROOT/scripts/queue.pl JOB=1:$bow_jobs $tmpfolder/align-to-dict.log.JOB $ROOT/scripts/generate-bow-features.sh $config $tmpfolder/s.in.JOB $tmpfolder/s.out.JOB $f2e $tmpfolder/out.f2e.JOB 
  $ROOT/scripts/queue.pl JOB=1:$bow_jobs $tmpfolder/align-to-dict.log.JOB $ROOT/scripts/generate-bow-features.sh $config $tmpfolder/s.out.JOB $tmpfolder/s.in.JOB $e2f $tmpfolder/out.e2f.JOB

  wait
  )
#  cat $test.$input_lang | $ROOT/tools/bow-translation $f2e - | python $ROOT/scripts/unigram-similarity-kl.py - $test.$output_lang $bow_constant > $base/bad.bow.$input_lang-$output_lang &
#  cat $test.$output_lang | $ROOT/tools/bow-translation $e2f - | python $ROOT/scripts/unigram-similarity-kl.py - $test.$input_lang $bow_constant > $base/bad.bow.$output_lang-$input_lang &
  touch $base/bad.bow.$input_lang-$output_lang $base/bad.bow.$output_lang-$input_lang
  rm $base/bad.bow.$input_lang-$output_lang $base/bad.bow.$output_lang-$input_lang
  for i in `seq 1 $[$bow_jobs]`; do
    cat $tmpfolder/out.f2e.$i >> $base/bad.bow.$input_lang-$output_lang
    cat $tmpfolder/out.e2f.$i >> $base/bad.bow.$output_lang-$input_lang
  done

fi

if [ ! -f $base/bad.ppl.$output_lang ]; then
  for lang in $input_lang $output_lang; do
(    vocab=$base/vocab.$lang
    cat $train.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | head -n $word_count | awk '{print$2}' > $vocab
    echo Training LM for $lang
    $srilm/ngram-count -order $ngram_order -vocab $vocab -text $train.$lang -lm $base/lm.$lang -kndiscount

    $srilm/ngram -lm $base/lm.$lang -order $ngram_order -ppl $test.$lang -debug 1 2>&1 \
      | grep "ppl1=" | grep zeroprobs | grep logprob | head -n -1 | awk '{print log($6)}' > $base/bad.ppl.$lang
) &
  done
fi

wait
