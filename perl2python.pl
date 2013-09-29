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
#  Purpose:                         Assignment 1 >> 'Perl to Python Compiler'.
###############################################################################

# Behave like unix filter and read in all lines from file.
while ($line = <>)
{
   
   # Start matching and translating.
   if ($line =~ /^#!/ && $. == 1) 
   {
      	
		# Translate Shebang '#!' line. 
		print "#!/usr/bin/python2.7 -u\n";
		
	} 
	elsif ($line =~ /^\s*#+/ || $line =~ /^\s*$/) 
	{
	
		# Blank lines & comment lines can be passed though unchanged.
		print $line;
		
	} 
	elsif ($line =~ /^\s*print\s*\(*"(.*)\\n"\)*[\s;]*$/) 
	{
	   # Process inner strings and varibles.
      $newSubPart = translatePrintSubPart($1);
		
		# Python's print adds a new-line character by default
		# so we need to delete it from the Perl print statement.
		print "print ".$newSubPart."\n";
	
	} 
	elsif ($line =~ /[\$\@\%]/)
	{
	   
      # Translate Perl variables.
      $line = checkAndOrTranslateVaribales($line);
		
		print $line."\n";
	} 
	else 
	{
	
		# Lines that can't be translated are turned into comments.
		print "# Could not translate: \"".$line."\"\n";
		
	}
	
}

# Function which translates variables -------------------------------
sub checkAndOrTranslateVaribales {
   
   my ($inputLine) = @_;
   
   # Scalers.
   if($inputLine =~ s/[^\\]*\$([a-zA-Z_1-9]+)/$1/g)
   {
      # Translate brackets for hash scalers, if exists.
      $inputLine =~ tr/{}/[]/;
   }
   
   # Arrays.
   if($inputLine =~ s/[^\\]*\@([a-zA-Z_1-9]+)/$1/g)
   {
      # Translate brackets if exists.
      $inputLine =~ tr/()/[]/;
   }
   
   # Hashes.
   if($inputLine =~ s/[^\\]*\%([a-zA-Z_1-9]+)/$1/g)
   {
      # Translate brackets and hash connectors, if exists.
      $inputLine =~ tr/()/{}/;
      
      $inputLine =~ s/\=\>/:/g;
   }
   
   return $inputLine;
}

# Function which translates the sub parts of a 'print' statement ----
sub translatePrintSubPart
{  
   my $inputLine = @_;
   my $result = '';
   
   @part = split(' ', $inputLine);
   
   # append etc.
} 



