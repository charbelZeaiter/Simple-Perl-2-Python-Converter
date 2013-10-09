#!/usr/bin/perl -w

# Some argument manipulation and string concatination.

$string = "";

foreach $i (0..$#ARGV) {
    $string .= $ARGV[$i];
}

print $string;
print "\n";
