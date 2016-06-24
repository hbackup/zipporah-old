#!/bin/bash

function check_equal_lines {
  n1=`wc -l $1 | awk '{print $1}'`
  n2=`wc -l $2 | awk '{print $1}'`
  if [ $n1 -ne $n2 ]; then
    echo "Unequal number of lines: $1 and $2" && exit 1
  fi
}

config=$1
. $config

if [ -f $working/$id/step-1/.done.$iter ]; then
  echo "[iter-$iter] [step-1] Already finished."
  exit
fi

mkdir -p $working/$id/step-1

echo -n "[iter-$iter] [step-1] starts," && grep "^#1:" steps.info | awk -F ':' '{print $2}'

if [ ! -f $working/$id/step-1/bad.clean.short.$input_lang ]; then
  echo "[iter-$iter] [step-1] processing bad corpus"
  if [ -f $clean_stem_bad.$input_lang ] && [ -f $clean_stem_bad.$output_lang ]; then
    check_equal_lines $clean_stem_bad.$input_lang $clean_stem_bad.$output_lang
    ln -s $clean_stem_bad.$input_lang $working/$id/step-1/bad.clean.$input_lang
    ln -s $clean_stem_bad.$output_lang $working/$id/step-1/bad.clean.$output_lang
  else
    check_equal_lines $raw_stem_bad.$input_lang $raw_stem_bad.$output_lang
    for i in $input_lang $output_lang; do
      $ROOT/scripts/lib/raw-to-clean.sh $config $i $raw_stem_bad.$i $working/$id/step-1/bad.clean.$i > $working/$id/LOGs/raw-to-clean-bad.log &
    done
    wait
  fi

  for c in bad; do
    $moses/scripts/training/clean-corpus-n.perl \
      $working/$id/step-1/$c.clean $input_lang $output_lang \
      $working/$id/step-1/$c.clean.short 1 80
  done
fi

echo "[iter-$iter] [step-1] processing good corpus"

if [[ $raw_stem_good =~ ^[0-9]+$ ]]; then
  mkdir -p $working/$id/step-1/iter-1
  k=$raw_stem_good
  n=`wc -l $working/$id/step-1/$c.clean.short.$input_lang | awk '{print $1}'`

  if [ $iter -eq 1 ]; then
    echo "[iter-1] [step-1] randomly chooose subset as good data"
    $ROOT/tools/get-rand-index $n $k > $working/$id/step-1/iter-1/good-index-random
    $ROOT/tools/get-lines $working/$id/step-1/iter-1/good-index-random $working/$id/step-1/$c.clean.short.$input_lang > $working/$id/step-1/iter-1/good.clean.$input_lang
    $ROOT/tools/get-lines $working/$id/step-1/iter-1/good-index-random $working/$id/step-1/$c.clean.short.$output_lang > $working/$id/step-1/iter-1/good.clean.$output_lang
  else
    echo "[iter-1] [step-1] pick best data from last iteration"
    head -n $k $working/$id/step-6/iter-$[$iter-1]/bad/sorted | awk '{print $2}' > $working/$id/step-1/iter-$iter/good-index
    $ROOT/tools/get-lines $working/$id/step-1/iter-$iter/good-index-random $working/$id/step-1/$c.clean.short.$input_lang > $working/$id/step-1/iter-$iter/good.clean.$input_lang
    $ROOT/tools/get-lines $working/$id/step-1/iter-$iter/good-index-random $working/$id/step-1/$c.clean.short.$output_lang > $working/$id/step-1/iter-$iter/good.clean.$output_lang
  fi
  clean_stem_good=$working/$id/step-1/iter-$iter/good.clean

# no need to check anything now
  exit
fi

if [ -f $clean_stem_good.$input_lang ] && [ -f $clean_stem_good.$output_lang ]; then
  check_equal_lines $clean_stem_good.$input_lang $clean_stem_good.$output_lang
else
  check_equal_lines $raw_stem_good.$input_lang $raw_stem_good.$output_lang
  for i in $input_lang $output_lang; do
    $ROOT/scripts/lib/raw-to-clean.sh $config $i $raw_stem_good.$i $working/$id/step-1/good.clean.$i > $working/$id/LOGs/raw-to-clean-good.log &
  done
  wait
fi 

for c in good; do
  $moses/scripts/training/clean-corpus-n.perl \
    $working/$id/step-1/$c.clean $input_lang $output_lang \
    $working/$id/step-1/$c.clean.short 1 80
done

touch $working/$id/step-1/.done.$iter
echo "[iter-$iter] [step-1] finished."
