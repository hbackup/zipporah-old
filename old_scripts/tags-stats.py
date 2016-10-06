#!/bin/python

import sys
import datetime
import math
from collections import OrderedDict

def getType(word):
  parts = word.split('_')
  return parts[len(parts) - 1]

def main():
  argv = sys.argv[1:]
  input_file = argv.pop(0)
  output_file = argv.pop(0)

  f = open(input_file, 'r')
  pos_count = OrderedDict()
#  pos_count = {}
  for line in f:
    words = line.split()
    for word in words:
      pos = getType(word)
      if pos in pos_count:
        pos_count[pos] = 1 + pos_count[pos]
      else:
        pos_count[pos] = 1

  if (output_file == "-"):
    g = sys.stdout
  else:
    g = open(output_file, 'w')
  for k, v in pos_count.items():
    print >> g, k, v

if __name__ ==  "__main__":
  main()

