cd tools

for i in bow-translation get-lines get-rand-index; do
  g++ $i.cc -O2 -std=c++11 -o $i
done
