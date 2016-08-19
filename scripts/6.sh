#!/bin/bash

config=$1

. $config

if [ -f $working/$id/.done.$iter.6 ]; then
  echo $working/$id/.done.$iter.6 exist
#  exit
fi

echo "[iter-$iter] [step-6] Starts"

base=$working/$id/iter-$iter/step-6
mkdir -p $base
#mkdir -p $base/good
mkdir -p $base/bad

#[ ! -f $base/score.good ] && cat $working/$id/iter-$iter/step-5/score.good > $base/score.good
[ ! -f $base/score.bad ] && cat $working/$id/iter-$iter/step-5/score.bad  > $base/score.bad

k=$output_words

#echo "[iter-$iter] [step-6] generating the subset that is most similar to the good data"
#[ ! -f $base/good/sorted ] && cat $base/score.good | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/good/sorted

false && (
echo "[iter-$iter] [step-6] generating the subset that is most concentrated in the bad data"
[ ! -f $base/bad/sorted ] && cat $base/score.bad  | awk '{print $1, NR-1}' | sort -n -r -k1 > $base/bad/sorted

#for i in bad good; do
for i in bad; do
  cat $base/$i/sorted | awk '{print $2}' > $base/$i/index

  [ ! -f $working/$id/iter-1/step-1/bad.clean.short.pasted ] && \
    paste $working/$id/iter-1/step-1/bad.clean.short.$input_lang $working/$id/iter-1/step-1/bad.clean.short.$output_lang > $working/$id/iter-1/step-1/bad.clean.short.pasted

  $ROOT/tools/get-lines-by-words $base/$i/index $working/$id/iter-1/step-1/bad.clean.short.pasted $k > $base/$i/train$k.pasted

  cat $base/$i/train$k.pasted | awk -F '\t' '{print $1}' > $base/$i/train$num_lines_selected.$input_lang
  cat $base/$i/train$k.pasted | awk -F '\t' '{print $2}' > $base/$i/train$num_lines_selected.$output_lang
done

echo "[iter-$iter] [step-6] generating a random subset for comparison"

mkdir -p $base/rand/
cat $base/bad/index | shuf > $base/rand/index
for i in rand; do
  $ROOT/tools/get-lines-by-words $base/$i/index $working/$id/iter-1/step-1/bad.clean.short.pasted $k > $base/$i/train$k.pasted

  cat $base/$i/train$k.pasted | awk -F '\t' '{print $1}' > $base/$i/train$num_lines_selected.$input_lang
  cat $base/$i/train$k.pasted | awk -F '\t' '{print $2}' > $base/$i/train$num_lines_selected.$output_lang
done
)
rm -f $working/$id/train.??
rm -f $working/$id/rand.??

ln -s $base/bad/train$num_lines_selected.$input_lang $working/$id/train.$input_lang
ln -s $base/bad/train$num_lines_selected.$output_lang $working/$id/train.$output_lang

ln -s $base/rand/train$num_lines_selected.$input_lang $working/$id/rand.$input_lang
ln -s $base/rand/train$num_lines_selected.$output_lang $working/$id/rand.$output_lang


touch $working/$id/.done.$iter.6

echo "[iter-$iter] [step-6] finished"
