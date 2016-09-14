#!/bin/python

# For the tree-tagger

import sys
import datetime
import math
import re

def main():
  pattern = re.compile("^<EOS>")

  for line in sys.stdin:
    words = line.split()
      
    if pattern.match(words[0]):
      print "NEWLINE____"
    else:
      # normal lin
      print words[1],


if __name__ ==  "__main__":
  main()
