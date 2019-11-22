#!/usr/bin/env python
import os
import sys

if __name__ == "__main__":
    print(os.getcwd())
    print(os.uname())
    
try:
    filename = 'config.txt'
    f = open(filename, 'rU') 
    text = f.read() 
    f.close() 

except IOError:
    print('Missing file: ' + filename) 
