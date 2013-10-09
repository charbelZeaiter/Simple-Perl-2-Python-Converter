#!/usr/bin/perl -w

# testing print with some hashes and new formating.

$cache{"a"} = 10;
$cache{"b"} = 8;

print ($cache{"a"} % $cache{"b"}), "\n", "\n", "Hello";
