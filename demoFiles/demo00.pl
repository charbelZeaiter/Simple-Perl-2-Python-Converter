#!/usr/bin/perl -w

# Program that looks into a file named 'test.txt' and prints out its contents.

@cache = ();

open(F, "<test.txt");

foreach $line (<F>)
{
   push(@cache, $line);
}

foreach $line (@cache)
{
   print "Retrieved: $line";
}

close F;
