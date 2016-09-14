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

base=$working/$id/step-1
#[ -d $base ] && rm $base -r
mkdir -p $working/$id
mkdir -p $base

echo -n "[step-1] starts," && grep "^#1:" steps.info | awk -F ':' '{print $2}'

if [ ! -f $working/$id/step-1/bad.clean.short.$input_lang ]; then
  echo "[step-1] processing bad corpus"
  if [ -f $clean_stem_bad.$input_lang ] && [ -f $clean_stem_bad.$output_lang ]; then
    check_equal_lines $clean_stem_bad.$input_lang $clean_stem_bad.$output_lang
    ln -s $clean_stem_bad.$input_lang  $working/$id/step-1/bad.clean.$input_lang
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
      $working/$id/step-1/$c.clean.short 6 80
  done
fi

echo "[step-1] processing good corpus"

if [[ $raw_stem_good =~ ^[0-9]+$ ]]; then
  k=$raw_stem_good
  n=`wc -l $working/$id/step-1/bad.clean.short.$input_lang | awk '{print $1}'`

  echo "[step-1] randomly chooose subset as good data"
  $ROOT/tools/get-rand-index $n $k > $base/good-index-random
  $ROOT/tools/get-lines $base/good-index-random $base/bad.clean.short.$input_lang  > $base/good.clean.$input_lang
  $ROOT/tools/get-lines $base/good-index-random $base/bad.clean.short.$output_lang > $base/good.clean.$output_lang

  clean_stem_good=$base/good.clean
  ln -s $clean_stem_good.$input_lang $clean_stem_good.short.$input_lang
  ln -s $clean_stem_good.$output_lang $clean_stem_good.short.$output_lang

# no need to check anything now
  exit
fi

if [ -f $clean_stem_good.$input_lang ] && [ -f $clean_stem_good.$output_lang ]; then
  check_equal_lines $clean_stem_good.$input_lang $clean_stem_good.$output_lang
  ln -s $clean_stem_good.$input_lang  $base/good.clean.$input_lang
  ln -s $clean_stem_good.$output_lang $base/good.clean.$output_lang
else
  check_equal_lines $raw_stem_good.$input_lang $raw_stem_good.$output_lang
  for i in $input_lang $output_lang; do
    $ROOT/scripts/lib/raw-to-clean.sh $config $i $raw_stem_good.$i $base/good.clean.$i > $working/$id/LOGs/raw-to-clean-good.log &
  done
  wait
fi 

for c in good; do
  $moses/scripts/training/clean-corpus-n.perl \
    $base/$c.clean $input_lang $output_lang \
    $base/$c.clean.short 1 80
done

touch $working/$id/.done.1
echo "[step-1] finished."
