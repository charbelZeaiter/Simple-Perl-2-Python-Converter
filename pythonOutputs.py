#!/usr/bin/python2.7 -u

answer = 42
print answer

#!/usr/bin/python2.7 -u

answer = 6 * 7
print answer

#!/usr/bin/python2.7 -u

answer = 1 + 7 * 7 - 8
print answer

#!/usr/bin/python2.7 -u
factor0 = 6
factor1 = 7
answer = factor0 * factor1
print answer

#!/usr/bin/python2.7 -u

factor0 = 6
factor1 = 7
print factor0 * factor1

#!/usr/bin/python2.7 -u

DEBUG 0
LIMIT 5

#!/usr/bin/python2.7 -u

x = int("5")
y = int("20")

print x + y

#!/usr/bin/python2.7 -u

x = float("5.5")
y = float("20.1")

print x + y

#!/usr/bin/python2.7 -u

answer = 41
if answer > 0:
    answer = answer + 2
if answer == 43:
    answer = answer - 1
print answer

#!/usr/bin/python2.7 -u
answer = 0
while answer < 36:
    answer = answer + 7
print answer

#!/usr/bin/python2.7 -u

x = 1
while x <= 10:
    print x
    x = x + 1

#!/usr/bin/python2.7 -u

x=0
while x <= 10:
   print x
   x=x+1


#!/usr/bin/python2.7 -u
import sys

x=0
while x <= 10:
   print x
   
   j=0
   while j <= 199:
      sys.stdout.write("Hello")
      j=j+5
   x=x+1

#!/usr/bin/python2.7 -u
import sys

while 1:
    print "Give me cookie"
    line = sys.stdin.readline()
    line = line.rstrip()
    if line == "cookie":
        break
print "Thank you"

#!/usr/bin/python2.7 -u
import sys
# writen by andrewt@cse.unsw.edu.au as a COMP2041 example
# implementation of /bin/echo

print ' '.join(sys.argv[1:])

#!/usr/bin/python2.7 -u

str = "hello world are you there"

print str.split(' ')

#!/usr/bin/python2.7 -u

x = x + 1

shadow[4] = shadow[4] - 1

jig['kell'] = jig['kell'] + 1

#!/usr/bin/python2.7 -u
import sys

for arg in sys.argv[1:]:
    print arg

#!/usr/bin/python2.7 -u

for i in xrange(0, 5):
    print i

#!/usr/bin/python2.7 -u

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

#!/usr/bin/python2.7 -u

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

#!/usr/bin/python2.7 -u
import sys

sys.stdout.write("Hello there "+x+" jiggs")







