cd tools

#for i in bow-translation-improved lex-prune get-rand-index get-lines get-lines-by-words select-by-url \
#      align-to-dict; do
for i in bow-translation align-to-dict; do
#  echo g++ $i.cc -O2 -std=c++11 -o $i
  g++ $i.cc -O2 -std=c++11 -o $i
#  g++ $i.cc -g -std=c++11 -o $i
done
