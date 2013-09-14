#!/usr/bin/perl -w

###############################################################################
#  File Name:                       perl2python.pl
# 
#  Author:                          Charbel Zeaiter
#
#  CSE username:                    cjze477
# 
#  Student Email:                   z3419481@student.unsw.edu.au
#
#  Date Created:                    14/09/2013
#
#  Purpose:                         Assignment 1 >> Perl to Python Compiler.
###############################################################################

# Behave like unix filter and read in lines.
while ($line = <>)
{
   # Start matching and translating.
   if ($line =~ /^#!/ && $. == 1) {
      	
		# Translate Shebang '#!' line. 
		print "#!/usr/bin/python2.7 -u\n";
		
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
	
		# Blank lines & comment lines can be passed though unchanged.
		print $line;
		
	} elsif ($line =~ /^\s*print\s*\(*"(.*)\\n"\)*[\s;]*$/) {

		# Python's print adds a new-line character by default
		# so we need to delete it from the Perl print statement
		print "print \"".$1."\"\n";
		
	} else {
	
		# Lines that can't be translated are turned into comments.
		print "# Could not translate: \"".$line."\"\n";
		
	}
}






