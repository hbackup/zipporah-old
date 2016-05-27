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
    $ROOT/scripts/lib/raw-to-clean.sh $config $raw_stem_good.$i $working/$id/step-1/good.clean.$i
  done
fi

