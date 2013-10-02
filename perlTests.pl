#!/usr/bin/perl -w

$answer = 42;
print "$answer\n";

#!/usr/bin/perl -w

$answer = 6 * 7;
print "$answer\n";

#!/usr/bin/perl -w

$answer = 1 + 7 * 7 - 8;
print "$answer\n";

#!/usr/bin/perl -w
$factor0 = 6;
$factor1 = 7;
$answer = $factor0 * $factor1;
print "$answer\n";

#!/usr/bin/perl -w

$factor0 = 6;
$factor1 = 7;
print $factor0 * $factor1, "\n";

#!/usr/bin/perl -w

use constant DEBUG => 0;
use constant LIMIT => 5;

#!/usr/bin/perl -w

$x = "5";
$y = "20";

print $x + $y;

#!/usr/bin/perl -w

$x = "5.5";
$y = "20.1";

print $x + $y;

#!/usr/bin/perl -w

$answer = 41;
if ($answer > 0) {
    $answer = $answer + 2;
}
if ($answer == 43) {
    $answer = $answer - 1;
}
print "$answer\n";

#!/usr/bin/perl -w
$answer = 0;
while ($answer < 36) {
    $answer = $answer + 7;
}
print "$answer\n";

#!/usr/bin/perl -w

$x = 1;
while ($x <= 10) {
    print "$x\n";
    $x = $x + 1;
}

#!/usr/bin/perl -w

for ($x=0;$x <= 10;$x=$x+1) {
   print "$x\n";
}


#!/usr/bin/perl -w

for ($x=0;$x <= 10;$x=$x+1) {
   print "$x\n";
   
   for($j=0;$j <= 199;$j=$j+5)
   {
      print "Hello";
   }
}

#!/usr/bin/perl -w

while (1) {
    print "Give me cookie\n";
    $line = <STDIN>;
    chomp $line;
    if ($line eq "cookie") {
        last;
    }
}
print "Thank you\n";









