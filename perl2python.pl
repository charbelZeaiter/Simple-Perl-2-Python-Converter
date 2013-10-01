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

# Global flags and variables.
$loopFlag{"endedMatch"} = "";
$loopFlag{"incrementor"} = "";

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
	   
	   # Operator translations which can occur anywhere at any time.
	   $line = parseOperators($line);
	   
	   # Call print parsing function.
	   $line = parsePrint($line);
	   
	   print $line;
	}
	elsif ($line =~ m/\s*if\s*\(|\s*elsif\s*\(|\s*else\s*\{|\s*while\s*\(|\s*for\s*\(/)
	{
	   # Detected a control structure.
      
      # Control structure translation.
	   $line = parseControlStructures($line);
	   
	   # Operator translations which can occur anywhere at any time.
	   $line = parseOperators($line);

	   # Translate Perl variables.
      $line = checkAndOrTranslateVaribales($line);
	   
	   print $line;
	} 
	elsif ($line =~ m/^\s*next\;|^\s*last\;/)
	{
	   # Detected loop constructs.
	   
	   # Translate loop construct 'next' to 'continue';
	   $line =~ s/^(\s*)next\;/$1continue;/g;
	   
	   # Translate loop construct 'last' to 'break';
	   $line =~ s/^(\s*)last\;/$1break;/g;
	   
	   print $line;
	}
	elsif ($line =~ m/use constant [_a-zA-Z0-9]+ \=\> [0-9]+\;/i)
	{
	   # Detected numeric constant.
	   
	   # Parse constant code.
	   $line = parseNumericConstant($line);
	   
	   print $line;
	}
	elsif($line =~ m/\s*\{\s*|(\s*)\}\s*/)
	{
	   # Detected curly bracket.
	   
	   $spaces = $1;
	   
	   # Process curly brackets.
      $line = parseCurlyBrackets($line, $spaces);
      
      print $line if($line ne "");
	}
	elsif ($line =~ /[\$\@\%]/)
	{
	   # Detected Variable line.
	   
	   # Operator translations which can occur anywhere at any time.
	   $line = parseOperators($line);
      
      # Translate Perl variables.
      $line = checkAndOrTranslateVaribales($line);
		
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
sub checkAndOrTranslateVaribales 
{
   
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
   elsif($line =~ /^(\s*)print\s*\(?"(.*)\\n*"\)?[\s;]*$/)
   {
	   # Get sub part inside print statement.
	   
      # Process inner strings and varibles.
      $newSubPart = translatePrintSubPart($2);
		
	   # Python's print adds a new-line character by default
	   # so we need to delete it from the Perl print statement.
	   $result = $1."print ".$newSubPart."\n";
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
      $inputLine =~ s/(\s*)([a-zA-Z0-9_\$\:\=]+)(\s*)/"$2"/g;
      
      # Preserve spacing format.
      $inputLine =~ s/(\"\"\$)/ $1/g;
      $inputLine =~ s/(\"\")([a-zA-Z0-9_\:\=])/$1 $2/g;
      
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

# Function which translates logical, comparison and bitwise operators ###################
#########################################################################################
sub parseOperators 
{
   my ($inputLine) = @_;
   
   # Logical operators: || && ! and or not 
   
   # Translate all '||' to 'or'.
   $inputLine =~ s/ \|\| / or /g;
   
   # Translate all '&&' to 'and'.
   $inputLine =~ s/ \&\& / and /g;
   
   # Comparison operators: <, <=, >, >=, <>, !=, ==
   
   # Translate stringwise 'lt' to '<'.
   $inputLine =~ s/ lt / < /g;
   
   # Translate stringwise 'gt' to '>'.
   $inputLine =~ s/ gt / > /g;
   
   # Translate stringwise 'le' to '<='.
   $inputLine =~ s/ le / <= /g;
   
   # Translate stringwise 'gr' to '>='.
   $inputLine =~ s/ ge / >= /g;
   
   # Translate stringwise 'eq' to '=='.
   $inputLine =~ s/ eq / == /g;
   
   # Translate stringwise 'ne' to '!='.
   $inputLine =~ s/ ne / != /g;
   
   # Bitwise operators: | ^ & << >> ~ 
   # All are the same as Perl.
   
   return $inputLine;
}

# Function which translates perl control structures #####################################
#########################################################################################
sub parseControlStructures
{
   my ($inputLine) = @_;
   
   
   if($inputLine =~ m/^(\s*if|while)\s*\((.*?)\)\s*\{?/)
   {  
      # Translate 'if' or 'while'.      
      $inputLine = $1." ".$2.":\n";
   }
   elsif($inputLine =~ m/^(\s*)elsif\s*\((.*?)\)\s*\{?/)
   {
      # Translate 'elsif'.
      $inputLine = $1."elif ".$2.":\n";
   }
   elsif($inputLine =~ m/(\s*)else\s*\{?/)
   {  
      # Translate 'else'.
      $inputLine = "else:\n";
   }
   elsif($inputLine =~ m/^(\s*)for\s*\((.*?)\;(.*?)\;(.*?)\)\s*\{?/)
   {
      $spaces = $1;
      $loopVariable = $2;
      $loopCondition = $3;
      $loopIncrementor = $4;
      
      $loopFlag{"endedMatch"} = $spaces;
      $loopFlag{"incrementor"} = checkAndOrTranslateVaribales($loopIncrementor);
      
      $inputLine = $spaces.$loopVariable."\n";
      $inputLine .= $spaces."while ".$loopCondition.":\n";
      
   }
   
   return $inputLine;
}

# Function which processes perl curly brackets ##########################################
#########################################################################################
sub parseCurlyBrackets
{  
   my ($inputLine, $spaces) = @_;
   my $result = "";

   if($inputLine =~ m/(\s*)\}(\s*)/)
   {
	   if($loopFlag{"endedMatch"} ne "" || $loopFlag{"incrementor"} ne "")
	   {
	      # Checking to see if curly bracket belongs to loop construct.
	      
	      if($spaces eq $loopFlag{"endedMatch"})
	      {  
	         $result = "   ".$loopFlag{"endedMatch"}.$loopFlag{"incrementor"}."\n";
	         
	         $loopFlag{"endedMatch"} = "";
	         $loopFlag{"incrementor"} = "";
	      }
	   }
	}
	
	return $result;   
}





