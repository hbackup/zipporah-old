#!/bin/bash

# this file has location variables used throughout the system

# locations
#==============================================================================
working=/export/a11/hxu/automatic/working
#==============================================================================

# binaries
#==============================================================================
moses=/export/a11/hxu/mosesdecoder
tagger=/export/a11/hxu/tools/stanford-postagger-full-2015-12-09
clust=/export/a11/hxu/tools/cluster-3.6.7/clust

#==============================================================================
# corpus
# we have 3 set of corpus needed. 
# ref corpus - to train a MT system and we use its lex tables
# good corpus - to extract features and train a GMM
# bad corpus - the corpus which we try to select a good subset
# ref and good corpus could be the same 
#==============================================================================
input_lang=fr
output_lang=en
raw_stem_good=
clean_stem_good=
raw_stem_ref=
clean_stem_ref=
raw_stem_bad=

output_percent=0.1
lang_pair=${input_lang}-${output_lang}

#==============================================================================
# features to use
#==============================================================================
bow_feat=true # probably the most important feature
bow_thresh=0.05 # only pick entries in lex table when prob >= thresh
                # 1 means pick most likely translation

pos_feat=true # need stanford tagger
pos_num=10 # only pick top pos_num most common tags for each side:w

length_feat=true
length_ratio=true

non_word_agree_feat=true

#==============================================================================
# GMM
#==============================================================================
num_gauss=8