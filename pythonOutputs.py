#!/usr/bin/python2.7 -u
import sys, fileinput, re



answer = 42
print answer



answer = 6 * 7
print answer



answer = 1 + 7 * 7 - 8
print answer



factor0 = 6
factor1 = 7
answer = factor0 * factor1
print answer



factor0 = 6
factor1 = 7
print factor0 * factor1



DEBUG 0
LIMIT 5



x = int("5")
y = int("20")

print x + y



x = float("5.5")
y = float("20.1")

print x + y



answer = 41
if answer > 0:
    answer = answer + 2
if answer == 43:
    answer = answer - 1
print answer



answer = 0
while answer < 36:
    answer = answer + 7
print answer



x = 1
while x <= 10:
    print x
    x = x + 1



x=0
while x <= 10:
   print x
   x=x+1



x=0
while x <= 10:
   print x
   
   j=0
   while j <= 199:
      sys.stdout.write("Hello")
      j=j+5
   x=x+1



while 1:
    print "Give", "me", "cookie"
    line = sys.stdin.readline()
    line = line.rstrip()
    if line == "cookie":
        break
print "Thank", "you"



# writen by andrewt@cse.unsw.edu.au as a COMP2041 example
# implementation of /bin/echo

print ' '.join(sys.argv[1:])



str = "hello world are you there"

print str.split(' ')



x += 1

shadow[4] -= 1

jig['kell'] += 1



for arg in sys.argv[1:]:
    print arg



for i in xrange(0, 4 + 1):
    print i



count = 0
i = 2
while i < 100:
    k = i / 2
    j = 2
    while j <= k:
        k = i % j
        if k == 0:
            count = count - 1
            break
        k = i / 2
        j = j + 1
    count = count + 1
    i = i + 1
print count



n = 1
while n <= 10:
    total = 0
    j = 1
    while j <= n:
        i = 1
        while i <= j:
            total = total + i
            i = i + 1
        j = j + 1
    print total
    n = n + 1



sys.stdout.write("Hello there "+x+" jiggs")



print "Hello", "there"

sys.stdout.write("Hello thereLol")



for line in fileinput.input():
    line = line.rstrip()
    line = re.sub(r'[aeiou]', '', line)
    print line



for i in xrange(0 + 1, len(sys.argv) - 1 + 1):
    print sys.argv[i]



# written by andrewt@cse.unsw.edu.au as a COMP2041 lecture example
# Count the number of lines on standard input.

line = ""
line_count = 0
for line in sys.stdin:
    line_count += 1
print line_count, "lines"












