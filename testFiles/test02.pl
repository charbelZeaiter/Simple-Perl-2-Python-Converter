#!/usr/bin/perl -w

# testing unshift with a list instead of a variable.

@cache = ();

$x = "Chair";
@items = ("Ball", "Mouse", "Pen");

push(@cache, $x);
unshift(@cache, "Bottle");
unshift(@cache, @items);

print "@cache\n";


