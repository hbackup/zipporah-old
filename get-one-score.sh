#!/bin/bash

set -x

ngram_feat=false
input_lang=fr
output_lang=en
base=../working/one-score
srilm=/export/a11/hxu/tools/srilm/bin/i686-m64
ngram_order=3

#while :
#do
#  if [ -f ../working/3/step-2/feats/bad.bow.en-fr ]; then
#    break
#  fi
#  sleep 300
#done

i=final_weight

train=../working/4/step-1/good.clean.short
test=../working/4/step-1/bad.clean.short

word_count=10000

if [ $ngram_feat = true ]; then
  for lang in $input_lang $output_lang; do
    vocab=$base/vocab.$lang
    cat $train.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | tee $base/$lang.unigram.count | head -n $word_count | awk '{print$2}' > $vocab
    echo Training LM for $lang
    $srilm/ngram-count -order $ngram_order -vocab $vocab -text $train.$lang -lm $base/lm.$lang -kndiscount

    $srilm/ngram -lm $base/lm.$lang -order $ngram_order -ppl $test.$lang -debug 1 2>&1 \
      | grep "ppl1=" | grep zeroprobs | grep logprob | head -n -1 | awk '{print log($6)}' > $base/bad.ppl.$lang
  done
fi

#paste $test.?? | awk '{print NF}' > ../working/one-score/total_length

#paste ../working/3/step-2/feats/bad.bow.??-?? $base/bad.ppl.?? ../working/one-score/total_length | awk '{if($5>20)print NR-1,$1+$2+($3+$4)*2;else print NR-1,100}' | sort -k2n | awk '{print $1}' > ../working/one-score/index.$i

#paste ../working/3/step-2/feats/bad.bow.??-?? $base/bad.ppl.?? ../working/one-score/total_length | awk '{if($5>1)print NR-1,$1+$2+($3+$4)*2.2;else print NR-1,100}' | sort -k2n | awk '{print $1}' > ../working/one-score/index.$i
#paste ../working/3/step-2/feats/bad.bow.??-?? $base/bad.ppl.?? ../working/one-score/total_length | awk '{if($5>1)print NR-1,$1+$2+($3+$4)*3;else print NR-1,100}' | sort -k2n | awk '{print $1}' > ../working/one-score/index.$i

cat ../working/one-score/index.$i | shuf > ../working/one-score/index.random

i=random

for nw in 2000000 5000000 10000000 20000000 50000000 100000000; do
  tools/get-lines-by-words ../working/one-score/index.$i ../working/3/step-1/bad.clean.short.pasted $nw > ../working/one-score/clean.random.paste.$nw

  cat ../working/one-score/clean.random.paste.$nw | awk -F '\t' '{print $1}' > ../working/one-score/clean.random.$nw.fr
  cat ../working/one-score/clean.random.paste.$nw | awk -F '\t' '{print $2}' > ../working/one-score/clean.random.$nw.en
done

exit

#for nw in 2000000 5000000 10000000 20000000 50000000; do
for nw in 100000000; do
  tools/get-lines-by-words ../working/one-score/index.$i ../working/3/step-1/bad.clean.short.pasted $nw > ../working/one-score/clean.paste.$nw

  cat ../working/one-score/clean.paste.$nw | awk -F '\t' '{print $1}' > ../working/one-score/clean.$nw.fr
  cat ../working/one-score/clean.paste.$nw | awk -F '\t' '{print $2}' > ../working/one-score/clean.$nw.en
done

#vi -O ../working/one-score/clean.$i.??
