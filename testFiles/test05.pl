#!/usr/bin/perl -w

#  testing print with undeclared hashes and special characters.

$cache{"one"} = "the number 1";

print 'It\'s interesting how, '.$cache{"one"}." is the first number";
