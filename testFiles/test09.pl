#!/usr/bin/perl -w

# testing open and that print format for file writing is translated.

open(F, ">test.txt");

$x = 1;

print F "$x Hello there young one!\n";
