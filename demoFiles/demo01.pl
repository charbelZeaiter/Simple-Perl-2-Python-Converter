#!/usr/bin/perl -w
# Adapted from 2041 Course page.

print "Enter a number: ";
$a = <STDIN>;
if ($a < 0) {
    print "negative\n";
} elsif ($a == 0) {
    print "$a is zero\n";
} elsif ($a < 10) {
    print "$a is small\n";
} else {
    print "$a is large\n";
}
