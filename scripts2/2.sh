#!/bin/bash

config=$1

. $config

oldbase=$working/$id/step-1
base=$working/$id/step-2

set -x

mkdir -p $base

paste $oldbase/good.clean.short.$input_lang $oldbase/good.clean.short.$output_lang | sed "s=\t= ||| =g" > $base/good.pasted


$moses/tools/fast_align -i $base/good.pasted -d -o -v > $base/fast-align.1

$ROOT/tools/align-to-dict $oldbase/good.clean.short.$input_lang $oldbase/good.clean.short.$output_lang $base/fast-align.1 $base/dict.$input_lang-$output_lang $base/dict.$output_lang-$input_lang
