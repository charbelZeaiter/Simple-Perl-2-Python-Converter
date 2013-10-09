#!/usr/bin/perl -w

# Some array manipulation demo-ing push, pop, shift, reverse, unshift.

@myArr = ();

$x = "Hello";

@list = (4, 5, 6);

push(@myArr, $x);

print "@myArr\n";

push(@myArr, 989);

print "@myArr\n";

push(@myArr, "gigs");

print "@myArr\n";

push(@myArr, @list);

print "@myArr\n";

$v = pop(@myArr);

print "$v\n";

print "@myArr\n";

$k = shift(@myArr);

print "$k\n";

print "@myArr\n";

unshift(@myArr, "33");

print "@myArr\n";

@arrNew = (1,2,3);

unshift(@myArr, @arrNew);

print "@myArr\n"; 

@myArr2 = reverse(@myArr);

print "@myArr2\n"; 

print "@myArr\n";

@myArr = reverse(@myArr);

print "@myArr\n"; 


