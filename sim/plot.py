from pylab import *
import sys
import struct


def twos_comp(val, bits):
    """compute the 2's compliment of int value val"""
    if( (val&(1<<(bits-1))) != 0 ):
        val = val - (1<<bits)
    return val

#f = open('textdata_in.txt', 'r')
f = open(sys.argv[1], 'r')
# read all the lines into a list
lines = f.readlines()
y = [];
# lines is now a list of strings, we can iterate over them
for line in lines:
    line = line.strip() # what happens if you remove this line?
    #x = int(line, 2)
    x = twos_comp(int(line,2), len(line))
    #x = ~ (0xff - int(line, 2)) + 1
    #x = int(long(line,16)-2**32)
    #x = struct.unpack('>i', line.decode('bin'))
    #print x
    y.append(x)
    #print line

plot(y)
#plot(x,y)
xlabel('x-axis')
ylabel('y-axis')
title(r'$y=2\sin (2\pi(x-1/4))$')

show()
