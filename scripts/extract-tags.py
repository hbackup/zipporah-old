#!/usr/bin/python

import sys
import datetime
import math
from collections import OrderedDict

def getType(word):
#  print "word is ", word
  parts = word.split('_')
  return parts[len(parts) - 1]

def main():
  inp = sys.stdin

  for line in inp:
    words = line.split()

    for word in words:
      pos = getType(word)
      print pos,
    print ""

if __name__ ==  "__main__":
  main()
