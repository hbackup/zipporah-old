#!/bin/python

import sys
import datetime
import math
import re

webpattern = re.compile("[a-zA-Z]\.[a-zA-Z]")
numpattern = re.compile("[0-9]")

def IsNumber(s):
  return numpattern.match(s)

def IsWebpage(s):
  if (len(s) < 5):
    return False
  return webpattern.match(s)

def NumDiff(sent1, sent2):
  words1 = sent1.split()
  words2 = sent2.split()

  count = {}

  total_number = 0
  for word in words1:
    if not IsNumber(word) and not IsWebpage(word):
      continue
    
    total_number = total_number + 1
    # now we know it's a number
    if word in count:
      count[word] = count[word] + 1
    else:
      count[word] = 1
    
  for word in words2:
    if not IsNumber(word) and not IsWebpage(word):
      continue
    
    total_number = total_number + 1
    # now we know it's a number
    if word in count:
      count[word] = count[word] + 1
    else:
      count[word] = -1

  diff = 0
  for k, v in count.items():
    diff = diff + abs(v)

  ratio = 0.0
  if (total_number > 0):
    ratio = diff * 1.0 / total_number
  print ratio, total_number

def main():
  argv = sys.argv[1:]

  file1= argv.pop(0)
  file2 = argv.pop(0)

  f1 = open(file1, 'r')
  f2 = open(file2, 'r')

  for line1 in f1:
    line2 = f2.readline()
    NumDiff(line1, line2)

if __name__ ==  "__main__":
  main()
