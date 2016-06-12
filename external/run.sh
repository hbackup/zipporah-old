#!/bin/bash

tagger=http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tree-tagger-linux-3.2.tar.gz

sys=`uname`
if [ "$sys" == "Darwin" ]; then
  tagger=http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tree-tagger-MacOSX-3.2-intel.tar.gz
fi

[ -f tree-tagger-MacOSX-3.2-intel.tar.gz ] || wget $tagger

#tagger=`basename $tagger`

#mkdir -p tree-tagger
#cd tree-tagger

#tar -zxvf ../tree-tagger-MacOSX-3.2-intel.tar.gz

#cd ../

[ -f tagger-scripts.tar.gz ] || wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tagger-scripts.tar.gz

wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/install-tagger.sh

for i in spanish english french german italian russian; do
  [ -f $i-par-linux-3.2-utf8.bin.gz ] || wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/$i-par-linux-3.2-utf8.bin.gz
#  gunzip -k $i-par-linux-3.2-utf8.bin.gz
done

sh install-tagger.sh

exit

mkdir -p models
cd models

for i in spanish english french german italian russian; do
  [ -f $i-par-linux-3.2-utf8.bin.gz ] || wget http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/$i-par-linux-3.2-utf8.bin.gz
  gunzip -k $i-par-linux-3.2-utf8.bin.gz
done


