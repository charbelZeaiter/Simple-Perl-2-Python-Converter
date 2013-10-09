#!/usr/bin/perl -w

# Some nested loops and special shothand incrementors.

for ($i=0;$i<=2;$i++) {
   
   print "Zip!\n";
   
   for($j=3;$j>0;$j--)
   {
      print ">>>Zap!\n";
      
      for($k=0;$k<4;$k=$k+2)
      {
         print ">>>>>>Zoo!\n";
      }
   }
}
