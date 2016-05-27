#!/bin/python

import sys
import datetime
import math
from collections import OrderedDict

def getType(word):
#  print "word is ", word
  parts = word.split('_')
  return parts[len(parts) - 1]

def main():
  argv = sys.argv[1:]

#  print 'Argument List:', str(sys.argv)

  ref_file = argv.pop(0)
  input_file = argv.pop(0)
  output_file = argv.pop(0)

  r = open(ref_file, 'r')
  f = open(input_file, 'r')

  if (output_file == "-"):
    g = sys.stdout
  else:
    g = open(output_file, 'w')

#  pos_count = OrderedDict()
  pos_count = {}

  for pos in r:
    pos = pos.strip()
    pos_count[pos] = 0
  r.close()

#  print "accepted POS are", pos_count

  for line in f:
    for k, v in pos_count.items():
      pos_count[k] = 0

    words = line.split()
    for word in words:
      pos = getType(word)
#      print pos
      if pos in pos_count:
        pos_count[pos] = 1 + pos_count[pos]

    for k, v in pos_count.items():
      print >> g, k, v,
    print >> g, ""

  f.close()
  if (output_file != "-"):
    g.close()

if __name__ ==  "__main__":
  main()

#  a = [1, 3, 2, 5]
#  s = OrderedDict()
#  print s
#  for i in a:
#    print i
#    s[i] = i * 2
#
#  for key, v in s.items():
#    print key, v
    
