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

echo -n "running step " && grep "^#1:" steps.info

if [ -f $clean_stem_good.$input ] && [ -f $clean_stem_good.$output ]; then
  check_equal_lines $clean_stem_good.$input $clean_stem_good.$output
else
  check_equal_lines $raw_stem_good.$input $raw_stem_good.$output
  for i in $input $output; do
    $ROOT/scripts/lib/raw-to-clean.sh $config $i $raw_stem_good.$i $working/$id/step-1/good.clean.$i | tee $working/$id/LOGs/raw-to-clean-good.log
  done
fi 

if [ -f $clean_stem_bad.$input ] && [ -f $clean_stem_bad.$output ]; then
  check_equal_lines $clean_stem_bad.$input $clean_stem_bad.$output
else
  check_equal_lines $raw_stem_bad.$input $raw_stem_bad.$output
  for i in $input $output; do
    $ROOT/scripts/lib/raw-to-clean.sh $config $i $raw_stem_bad.$i $working/$id/step-1/bad.clean.$i | tee $working/$id/LOGs/raw-to-clean-bad.log
  done
fi

if [ "$clean_stem_good" != "$clean_stem_ref" ]; then
  if [ -f $clean_stem_ref.$input ] && [ -f $clean_stem_ref.$output ]; then
    check_equal_lines $clean_stem_ref.$input $clean_stem_ref.$output
  else
    check_equal_lines $raw_stem_ref.$input $raw_stem_ref.$output
    for i in $input $output; do
      $ROOT/scripts/lib/raw-to-clean.sh $config $i $raw_stem_ref.$i $working/$id/step-1/ref.clean.$i | tee $working/$id/LOGs/raw-to-clean-ref.log
    done
  fi
else
  for i in $input $output; do
    ln $working/$id/step-1/good.clean.$i $working/$id/step-1/ref.clean.$i
  done
fi
