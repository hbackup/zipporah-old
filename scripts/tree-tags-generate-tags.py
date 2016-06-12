#!/bin/python

# For the tree-tagger

import sys
import datetime
import math
import re

def main():
  pattern = re.compile("^LINE_SPECIAL_SYM")
  last_line_special = 0
  begin = 1

  for line in sys.stdin:
    words = line.split()
#    print words[1]
    if last_line_special == 1:
      # eat out the : character
      last_line_special = 0
      continue
      
    if pattern.match(words[0]):
      last_line_special = 1
      if begin == 0:
        print ""
      else:
        begin = 0
    else:
      # normal lin
      print words[1],


if __name__ ==  "__main__":
  main()
