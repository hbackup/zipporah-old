#!/bin/python

import sys
import datetime
import math
from collections import OrderedDict

def similarity(sent1, sent2):
  words1 = sent1.split()
  words2 = sent2.split()

  total_length = len(words1) + len(words2)

  count = {}

  for word in words1:
    if word in count:
      count[word] = count[word] + 1
    else:
      count[word] = 1

  for word in words2:
    if word in count:
      count[word] = count[word] - 1
    else:
      count[word] = -1

  ans = 0
  for k, v in count.items():
    ans += abs(v)

  return 1.0 - ans * 1.0 / total_length


def main():
  argv = sys.argv[1:]

  file1 = argv.pop(0)
  file2 = argv.pop(0)

  f1 = open(file1, 'r')
  f2 = open(file2, 'r')

  for line1 in f1:
#    print "read line", line1
    line2 = f2.readline()
#    print "read line", line2
    print similarity(line1, line2)

if __name__ ==  "__main__":
  main()

    

