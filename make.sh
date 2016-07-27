cd tools

for i in bow-translation-improved lex-prune get-lines get-rand-index; do
  g++ $i.cc -O2 -std=c++11 -o $i
#  g++ $i.cc -g -std=c++11 -o $i
done
