#!/usr/bin/perl -w

#########################################################################################
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
#########################################################################################

# Behave like unix filter and read in all lines from file.
while ($line = <>)
{
   
   # Start matching and translating.
   if ($line =~ /^#!/ ) 
   {#&& $. == 1
      # Detected ShaBang line.
      	
		# Translate Shebang '#!' line. 
		print "#!/usr/bin/python2.7 -u\n";
		
	} 
	elsif ($line =~ /^\s*#+/ || $line =~ /^\s*$/) 
	{
	   
		# Detected Blank lines & comment line, which can be passed though unchanged.
		print $line;
		
	} 
	elsif ($line =~ /^\s*print\s+/) 
	{
	   # Detected Print statement.
	   
	   # Call print parsing function.
	   $line = parsePrint($line);
	   
	   print $line;
	} 
	elsif ($line =~ /[\$\@\%]/)
	{
	   # Detected Variable line.
	   
      # Translate Perl variables.
      $line = checkAndOrTranslateVaribales($line);
		
		print $line;
	}
	elsif ($line =~ m/use constant [_a-zA-Z0-9]+ \=\> [0-9]+\;/i)
	{
	   # Detected numeric constant.
	   
	   # Parse constant code.
	   $line = parseNumericConstant($line);
	   
	   print $line;
	} 
	else 
	{
	
		# Lines that can't be translated are turned into comments.
		print "# Could not translate: \"".$line."\"\n";
		
	}
	
}

# Function which translates variables ###################################################
#########################################################################################
sub checkAndOrTranslateVaribales {
   
   my ($inputLine) = @_;

   # Scalers.
   if($inputLine =~ s/([^\\]*?)\$([a-zA-Z_1-9]+?)/$1$2/g)
   {
      # Translate brackets for hash scalers, if exists.
      $inputLine =~ tr/{}/[]/;
      
      # Cast assignments to int if only numbers in string.
      $inputLine =~ s/(\"[0-9]+\")/int($1)/g;
      
      # Cast assignments to float if decimals only in string.
      $inputLine =~ s/(\"[0-9]+\.[0-9]+\")/float($1)/g;
   }
   
   # Arrays.
   if($inputLine =~ s/([^\\]*?)\@([a-zA-Z_1-9]+?)/$1$2/g)
   {
      # Translate brackets if exists.
      $inputLine =~ tr/()/[]/;
   }
   
   # Hashes.
   if($inputLine =~ s/([^\\]*?)\%([a-zA-Z_1-9]+?)/$1$2/g)
   {
      # Translate brackets and hash connectors, if exists.
      $inputLine =~ tr/()/{}/;
      
      $inputLine =~ s/\=\>/:/g;
   }
   
   # Remove semi-colon.
   $inputLine =~ s/\;$//;
   
   return $inputLine;
}

# Function which handles overall parsing of the 'print' statement #######################
#########################################################################################
sub parsePrint
{
   my ($line) = @_;   
   my $result = "";
   
   # If alternate comma notation exists, remove.
	if($line =~ s/(^\s*print\s*.*?)\,\s*.*?;/$1;/g)
	{
	   $newSubPart = checkAndOrTranslateVaribales($line);
	      
	   $result = $newSubPart;
   }
   elsif($line =~ /^\s*print\s*\(*"(.*)\\n"\)*[\s;]*$/)
   {
	   # Get sub part inside print statement.
	        
      # Process inner strings and varibles.
      $newSubPart = translatePrintSubPart($1);
		
	   # Python's print adds a new-line character by default
	   # so we need to delete it from the Perl print statement.
	   $result = "print ".$newSubPart."\n";
   }
   else
   {
      $newSubPart = checkAndOrTranslateVaribales($line);
	      
	   $result = $newSubPart;
   }
   
   return $result;
}

# Function which translates the sub parts of a 'print' statement ########################
#########################################################################################
sub translatePrintSubPart
{  
   my ($inputLine) = @_;
   my $result = '';
   
   if($inputLine =~ /\s+/)
   {  
      # Case: Multiple words.
      
      # Put quotes around all sub parts of srring.
      $inputLine =~ s/(\s*)([a-zA-Z0-9_\$]+)(\s*)/"$2"/g;
      
      # Preserve spacing format.
      $inputLine =~ s/(\"\"\$)/ $1/g;
      $inputLine =~ s/(\"\")([a-zA-Z0-9_])/$1 $2/g;
      
      # Put concatenation symbols.
      $inputLine =~ s/\"\"/"+"/g;
      
      # Unquote variables. 
      $inputLine =~ s/\"(\$[a-zA-Z_0-9]+)\"/$1/g;
      
      # Trim any '+' signs at begining or end of string.
      $inputLine =~ s/^\++//;
      $inputLine =~ s/\++$//;
      
   }
   else
   {
      # Case: 1 word.
      if($inputLine =~ /\$/)
      {  
         # Variable.
         $result = $inputLine;
      }
      else
      {
         # Not variable.
         $result = "\"$inputLine\"";
      }
   }
   
   # Laslty, translate any variables.
   $result = checkAndOrTranslateVaribales($inputLine);
   
   return $result;
} 

# Function which translates numeric constants ###########################################
#########################################################################################
sub parseNumericConstant
{
   my ($inputLine) = @_;
   my $result = "";
   
   # Extract parts from code line.
   $inputLine =~ s/use constant ([_a-zA-Z0-9]+) \=\> ([0-9]+)\;/$1 $2/i or die("Unexpected error in 'parseNumericConstant' function. \n");
   
   $result = $inputLine;
   
   return $result;  
}
















