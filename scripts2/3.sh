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

if [ $bow_feat = true ] && [ ! -f $base/bad.bow.$input_lang-$output_lang ]; then
  echo getting BoW features
  echo using dictionary $e2f and $f2e

  cat $test.$input_lang | $ROOT/tools/bow-translation $f2e - | python $ROOT/scripts/unigram-similarity-kl.py - $test.$output_lang > $base/bad.bow.$input_lang-$output_lang &
  cat $test.$output_lang | $ROOT/tools/bow-translation $f2e - | python $ROOT/scripts/unigram-similarity-kl.py - $test.$input_lang > $base/bad.bow.$output_lang-$input_lang &

fi

if [ $ngram_feat = true ] && [ ! -f $bases/bad.ppl.$output_lang ]; then
  for lang in $input_lang $output_lang; do
(    vocab=$base/vocab.$lang
    cat $train.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | head -n $word_count | awk '{print$2}' > $vocab
    echo Training LM for $lang
    $srilm/ngram-count -order $ngram_order -vocab $vocab -text $train.$lang -lm $base/lm.$lang -kndiscount

    $srilm/ngram -lm $base/lm.$lang -order $ngram_order -ppl $test.$lang -debug 1 2>&1 \
      | grep "ppl1=" | grep zeroprobs | grep logprob | head -n -1 | awk '{print log($6)}' > $bases/bad.ppl.$lang
      ) &
  done
fi

wait
