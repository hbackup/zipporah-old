cd tools

for i in bow-translation get-lines get-rand-index; do
  g++ $i.cc -O2 -o $i
done
