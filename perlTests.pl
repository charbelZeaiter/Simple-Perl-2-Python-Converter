#!/usr/bin/perl -w



$answer = 42;
print "$answer\n";



$answer = 6 * 7;
print "$answer\n";



$answer = 1 + 7 * 7 - 8;
print "$answer\n";



$factor0 = 6;
$factor1 = 7;
$answer = $factor0 * $factor1;
print "$answer\n";



$factor0 = 6;
$factor1 = 7;
print $factor0 * $factor1, "\n";



use constant DEBUG => 0;
use constant LIMIT => 5;



$x = "5";
$y = "20";

print $x + $y;



$x = "5.5";
$y = "20.1";

print $x + $y;



$answer = 41;
if ($answer > 0) {
    $answer = $answer + 2;
}
if ($answer == 43) {
    $answer = $answer - 1;
}
print "$answer\n";



$answer = 0;
while ($answer < 36) {
    $answer = $answer + 7;
}
print "$answer\n";



$x = 1;
while ($x <= 10) {
    print "$x\n";
    $x = $x + 1;
}



for ($x=0;$x <= 10;$x=$x+1) {
   print "$x\n";
}



for ($x=0;$x <= 10;$x=$x+1) {
   print "$x\n";
   
   for($j=0;$j <= 199;$j=$j+5)
   {
      print "Hello";
   }
}



while (1) {
    print "Give me cookie\n";
    $line = <STDIN>;
    chomp $line;
    if ($line eq "cookie") {
        last;
    }
}
print "Thank you\n";



# writen by andrewt@cse.unsw.edu.au as a COMP2041 example
# implementation of /bin/echo

print join(' ', @ARGV), "\n";



$str = "hello world are you there";

print split(' ', $str);



$x++;

$shadow[4]--;

$jig{'kell'}++;



foreach $arg (@ARGV) {
    print "$arg\n";
}



foreach $i (0..4) {
    print "$i\n"
}



$count = 0;
$i = 2;
while ($i < 100) {
    $k = $i / 2;
    $j = 2;
    while ($j <= $k) {
        $k = $i % $j;
        if ($k == 0) {
            $count = $count - 1;
            last;
        }
        $k = $i / 2;
        $j = $j + 1;
    }
    $count = $count + 1;
    $i = $i + 1;
}
print "$count\n";



$n = 1;
while ($n <= 10) {
    $total = 0;
    $j = 1;
    while ($j <= $n) {
        $i = 1;
        while ($i <= $j) {
            $total = $total + $i;
            $i = $i + 1;
        }
        $j = $j + 1;
    }
    print "$total\n";
    $n = $n + 1;
}



print "Hello there $x jiggs";



print "Hello there", "\n";

print "Hello there", "Lol";



while ($line = <>) {
    chomp $line;
    $line =~ s/[aeiou]//g;
    print "$line\n";
}



foreach $i (0..$#ARGV) {
    print "$ARGV[$i]\n";
}



# written by andrewt@cse.unsw.edu.au as a COMP2041 lecture example
# Count the number of lines on standard input.

$line = "";
$line_count = 0;
while ($line = <STDIN>) {
    $line_count++;
}
print "$line_count lines\n";



$number = 0;
while ($number >= 0) {
    print "Enter number:\n";
    $number = <STDIN>;
    if ($number >= 0) {
        if ($number % 2 == 0) {
            print "Even\n";
        } else {
            print "Odd\n";
        }
    }
}
print "Bye\n";



print "Enter a number: ";
$a = <STDIN>;
if ($a < 0) {
    print "negative\n";
} elsif ($a == 0) {
    print "zero\n";
} elsif ($a < 10) {
    print "small\n";
} else {
    print "large\n";
}



%hash = ();

$x = 30;
$y = $x % 4;


$q = 2;
$z = $x % $q;

$hash{"$q"} = $z;

if(4 % 3)
{
   print $hash{"$q"}, "\n";
   print "$y\n";
}



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



$x = "hello ";

$y = "!!!!";
$k = "june";
$c = 34;

$x .= $c."The"."brown"."fox".$c.$y."over"."fence".$k;

$h = $c."The"."brown"."fox".$c.$y."over"."fence".$k;

print "$x\n";

print "$h\n";



open(F, ">test.txt");

$x = 1;

print F "$x Hello there young one!\n";



@cache = ();

open(F, "<test.txt");

foreach $line (<F>)
{
   push(@cache, $line);
}

print @cache;

close F;



$x = 666;

print "$x dfsf"."jndkjna";

print "$x dfsf"."jndkjna\n";









