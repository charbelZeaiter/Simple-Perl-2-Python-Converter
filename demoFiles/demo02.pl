#!/usr/bin/perl -w

# Some hash and modulas manipulation.

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
