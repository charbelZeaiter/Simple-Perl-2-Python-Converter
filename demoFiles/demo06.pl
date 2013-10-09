#!/usr/bin/perl -w

# Program which writes input to a file until '@@@' is entered.

open(F, ">test.txt");

while(1) {

   $input = <STDIN>;
   
   chomp($input);
   
   if($input eq "@@@")
   {
      last;
   }
   
   print F "$input \n";

}

close F;
