#!/usr/bin/perl -w

# Program using regex adapted from COMP2041 assignment page tests.

while ($line = <>) {
    chomp $line;
    $line =~ s/[aeiou]//g;
    print "$line\n";
}
