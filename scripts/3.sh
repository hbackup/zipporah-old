#!/bin/bash

config=$1

. $config

if [ -f $working/$id/.done.$iter.3 ]; then
  exit
fi

train=$working/$id/iter-$iter/step-1/good.clean.short
test=$working/$id/iter-1/step-1/bad.clean.short

echo "[iter-$iter] [step-3] Start"

old_feats=$working/$id/iter-1/step-3/feats
old_base=$working/$id/iter-1/step-3/
base=$working/$id/iter-$iter/step-3/
feats=$base/feats
mkdir -p $base
mkdir -p $feats

good_string=
bad_string=

if [ $ngram_feat = true ] && [ ! -f $feats/bad.ppl.$output_lang ]; then
  for lang in $input_lang $output_lang; do
    vocab=$base/vocab.$lang
    cat $train.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | head -n $word_count | awk '{print$2}' > $vocab
    echo Training LM for $lang
    $srilm/ngram-count -order $ngram_order -vocab $vocab -text $train.$lang -lm $base/lm.$lang -kndiscount

    echo Scoring for $lang
    $srilm/ngram -lm $base/lm.$lang -order $ngram_order -ppl $train.$lang -debug 1 2>&1 \
      | grep "ppl1=" | grep zeroprobs | grep logprob | head -n -1 | awk '{print log($6)}' > $feats/good.ppl.$lang

    $srilm/ngram -lm $base/lm.$lang -order $ngram_order -ppl $test.$lang -debug 1 2>&1 \
      | grep "ppl1=" | grep zeroprobs | grep logprob | head -n -1 | awk '{print log($6)}' > $feats/bad.ppl.$lang
  done
fi

if [ $bow_feat = true ] && [ ! -f $feats/bad.bow.e2f ]; then
  echo running bow
  echo generate unigram counts
  for l in $input_lang $output_lang; do
    cat $train.$l | sed "s= =\n=g" | sort | uniq -c > $feats/unigram.$l
  done

  $ROOT/tools/lex-prune $f2e $bow_thresh > ${f2e}.pruned_$bow_thresh
  $ROOT/tools/lex-prune $e2f $bow_thresh > ${e2f}.pruned_$bow_thresh

  echo generate translation scores
  $ROOT/scripts/run-bow-improved.sh $config $feats/unigram.$input_lang  $f2e.pruned_$bow_thresh $train.$input_lang $train.$output_lang > $feats/good.bow.f2e
  $ROOT/scripts/run-bow-improved.sh $config $feats/unigram.$output_lang $e2f.pruned_$bow_thresh $train.$output_lang $train.$input_lang > $feats/good.bow.e2f

  $ROOT/scripts/run-bow-improved.sh $config $feats/unigram.$input_lang  $f2e.pruned_$bow_thresh $test.$input_lang $train.$output_lang >  $feats/bad.bow.f2e
  $ROOT/scripts/run-bow-improved.sh $config $feats/unigram.$output_lang $e2f.pruned_$bow_thresh $test.$output_lang $train.$input_lang >  $feats/bad.bow.e2f
fi

if [ ! -f $feats/bad.length.ratio ]; then
  cat $train.$input_lang | awk '{print NF}' > $feats/good.$input_lang.length
  cat $train.$output_lang | awk '{print NF}' > $feats/good.$output_lang.length

  [ $iter -eq 1 ] && cat $test.$input_lang  | awk '{print NF}' > $feats/bad.$input_lang.length
  [ $iter -eq 1 ] && cat $test.$output_lang | awk '{print NF}' > $feats/bad.$output_lang.length
  [ $iter -ne 1 ] && ln -s $old_feats/bad.$input_lang.length  $feats/bad.$input_lang.length
  [ $iter -ne 1 ] && ln -s $old_feats/bad.$output_lang.length $feats/bad.$output_lang.length

  for i in good; do
    paste $feats/$i.$input_lang.length $feats/$i.$output_lang.length | awk '{print ($1)/($2)}' > $feats/$i.length.ratio
  done

  [ $iter -eq 1 ] && for i in bad; do
                       paste $feats/$i.$input_lang.length $feats/$i.$output_lang.length | awk '{print ($1)/($2)}' > $feats/$i.length.ratio
                     done
  [ $iter -ne 1 ] && ln -s $old_feats/bad.length.ratio $feats/bad.length.ratio
fi

if [ $pos_feat = true ] && [ ! -f $feats/bad.pos ]; then
  mkdir -p $base/tagged/
  echo "[step-3] running the tagger to generate PoS features"

#TODO delete the comments
  $ROOT/scripts/tag-pos.sh $config $train $input_lang  $base/tagged/good.$input_lang
  $ROOT/scripts/tag-pos.sh $config $train $output_lang $base/tagged/good.$output_lang

  cat $base/tagged/good.$input_lang  | head -n $pos_sample > $old_base/tagged/good.sample.$input_lang
  cat $base/tagged/good.$output_lang | head -n $pos_sample > $old_base/tagged/good.sample.$output_lang

  [ $iter -eq 1 ] && (
  $ROOT/scripts/tag-pos.sh $config $test $input_lang  $base/tagged/bad.$input_lang
  $ROOT/scripts/tag-pos.sh $config $test $output_lang $base/tagged/bad.$output_lang 
      )

  $ROOT/scripts/generate-pos-features.sh $config $old_base/tagged/good.sample $base/tagged/good
  [ $iter -eq 1 ] && $ROOT/scripts/generate-pos-features.sh $config $old_base/tagged/good.sample $base/tagged/bad

  for i in good; do
    for j in $input_lang $output_lang; do
      paste $feats/$i.$j.length $base/tagged/$i.$j.pos.count | awk '{for(i=2;i<=NF;i++)printf($i/(1+$1)" ");print""}' > $base/tagged/$i.$j.pos.count.ratio
    done
  done

  [ $iter -eq 1 ] && for i in bad; do
    for j in $input_lang $output_lang; do
      paste $feats/$i.$j.length $base/tagged/$i.$j.pos.count | awk '{for(i=2;i<=NF;i++)printf($i/(1+$1)" ");print""}' > $base/tagged/$i.$j.pos.count.ratio
    done
  done

  paste $base/tagged/good.$input_lang.pos.count.ratio $base/tagged/good.$output_lang.pos.count.ratio > $feats/good.pos
  [ $iter -eq 1 ] && paste $base/tagged/bad.$input_lang.pos.count.ratio $base/tagged/bad.$output_lang.pos.count.ratio > $feats/bad.pos
  [ $iter -ne 1 ] && ln -s $old_feats/bad.pos $feats/bad.pos
fi

if [ $pos_feat = true ] && [ $pos_ngram_feat = true ] && [ ! -f $feats/bad.pos.ppl.$output_lang ]; then
  echo Training n-gram on PoS tags...
  for lang in $input_lang $output_lang; do
    vocab=$base/vocab.pos.$lang
    cat $base/tagged/good.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | awk '{print$2}' > $vocab
    echo Training pos LM for $lang
    $srilm/ngram-count -order $pos_ngram_order -vocab $vocab -text $base/tagged/good.$lang -lm $base/lm.pos.$lang

    echo Scoring for $lang
    $srilm/ngram -lm $base/lm.pos.$lang -order $pos_ngram_order -ppl $base/tagged/good.$lang -debug 1 2>&1 | tee $feats/log.good.pos.ppl.$lang \
      | grep "ppl1=" | grep zeroprobs | grep logprob | head -n -1 | awk '{print log($6)}' > $feats/good.pos.ppl.$lang

    cat $base/tagged/bad.$lang | sed 's=^$=ZZZZZZZZ=g' > $base/tagged/bad.$lang.noemptyline
    $srilm/ngram -lm $base/lm.pos.$lang -order $pos_ngram_order -ppl $base/tagged/bad.$lang.noemptyline -debug 1 2>&1 | tee $feats/log.bad.pos.ppl.$lang \
      | grep "ppl1=" | grep zeroprobs | grep logprob | head -n -1 | awk '{print log($6)}' > $feats/bad.pos.ppl.$lang
  done
fi

if [ $non_word_agree = true ] && [ ! -f $feats/bad.agree ]; then
  python $ROOT/scripts/non-word-agreement.py $train.$input_lang $train.$output_lang > $feats/good.agree
  [ $iter -eq 1 ] && python $ROOT/scripts/non-word-agreement.py $test.$input_lang $train.$output_lang > $feats/bad.agree
  [ $iter -ne 1 ] && ln -s $old_feats/bad.agree $feats/bad.agree
fi

if [ $pos_feat = true ]; then
  good_string="$good_string $feats/good.pos"
  bad_string="$bad_string $feats/bad.pos"
fi

if [ $pos_ngram_feat = true ]; then
  for lang in $input_lang $output_lang; do
    good_string="$good_string $feats/good.pos.ppl.$lang"
    bad_string="$bad_string $feats/bad.pos.ppl.$lang"
  done
fi

if [ $ngram_feat = true ]; then
  for lang in $input_lang $output_lang; do
    good_string="$good_string $feats/good.ppl.$lang"
    bad_string="$bad_string $feats/bad.ppl.$lang"
  done
fi

if [ $bow_feat = true ]; then
  good_string="$good_string $feats/good.bow.f2e $feats/good.bow.e2f"
  bad_string="$bad_string $feats/bad.bow.f2e $feats/bad.bow.e2f"
fi

if [ $length_feat = true ]; then
  good_string="$good_string $feats/good.$input_lang.length $feats/good.$output_lang.length"
  bad_string="$bad_string $feats/bad.$input_lang.length $feats/bad.$output_lang.length"
fi

if [ $length_ratio = true ]; then
  good_string="$good_string $feats/good.length.ratio"
  bad_string="$bad_string $feats/bad.length.ratio"
fi

if [ $non_word_agree = true ]; then
  good_string="$good_string $feats/good.agree"
  bad_string="$bad_string $feats/bad.agree"
fi

echo $good_string
echo $bad_string

feats=$working/$id/iter-$iter/feats/
mkdir -p $feats

paste $good_string > $feats/good.feats
paste $bad_string > $feats/bad.feats

touch $working/$id/.done.$iter.3

echo "[iter-$iter] [step-3] finished"
