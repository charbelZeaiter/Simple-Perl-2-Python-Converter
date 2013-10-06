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

# Global flags and variables ###############
@translatedCode = ();

@loopEndSpaces = ();
@loopEndIncrementors = ();

$lastSheBangLineNum = 0;

$importSysFlag = 0;
$importFileInputFlag = 0;
$importREFlag = 0;

%variableTypeStore = ();
############################################

# Main Loop: Behave like unix filter and read in all lines.
while ($line = <>)
{
	
   # Start matching and translating.
   if ($line =~ /^#!/ ) 
   {#&& $. == 1------------------------------------------------------------------------CHANGE
      # Detected ShaBang line.
      	
		# Translate Shebang '#!' line. 
		push(@translatedCode, "#!/usr/bin/python2.7 -u\n");
		
		# Saving line number.
		$lastSheBangLineNum = $#translatedCode;
		
	} 
	elsif ($line =~ /^\s*#+/ || $line =~ /^\s*$/) 
	{
	   
		# Detected Blank lines & comment line, which can be passed though unchanged.
		push(@translatedCode, $line);
		
	} 
	elsif ($line =~ /^\s*print\s+/) 
	{
	   # Detected Print statement.
	   
	   # Function translation.
	   $line = parseFunctions($line);
	   
	   # I/O handle translation.
	   $line = parseIOs($line);
	   
	   # Operator translations which can occur anywhere at any time.
	   $line = parseOperators($line);
	   
	   # Call print parsing function.
	   $line = parsePrint($line);
	   
	   # Apply final casting prediction.
      applyTypeCasting($line);

	   push(@translatedCode, $line);
	}
	elsif ($line =~ m/\s*if\s*\(|\s*elsif\s*\(|\s*else\s*\{|\s*while\s*\(|\s*foreach\s*\(|\s*for\s*/)
	{
	   # Detected a control structure.
      
      # Function translation.
	   $line = parseFunctions($line);
	   
	   # I/O handle translation.
	   $line = parseIOs($line);
	   
      # Operator translations which can occur anywhere at any time.
	   $line = parseOperators($line);
      
	   # Translate Perl variables.
      $line = checkAndOrTranslateVaribales($line);
	   
	   # Control structure translation.
	   $line = parseControlStructures($line);
	   
	   # Apply final casting prediction.
      applyTypeCasting($line);
      
	   push(@translatedCode, $line);
	} 
	elsif ($line =~ m/^\s*next\;|^\s*last\;/)
	{
	   # Detected loop constructs.
	   
	   # Translate loop construct 'next' to 'continue';
	   $line =~ s/^(\s*)next\;/$1continue/g;
	   
	   # Translate loop construct 'last' to 'break';
	   $line =~ s/^(\s*)last\;/$1break/g;
	   
	   push(@translatedCode, $line);
	}
	elsif ($line =~ m/use constant [_a-zA-Z0-9]+ \=\> [0-9]+\;/i)
	{
	   # Detected numeric constant.
	   
	   # Parse constant code.
	   $line = parseNumericConstant($line);
	   
	   # Apply final casting prediction.
      applyTypeCasting($line);
      
	   push(@translatedCode, $line);
	}
	elsif ($line =~ /[\$\@\%]/)
	{
	   # Detected Variable line.
	   
	   # Function translation.
	   $line = parseFunctions($line);
	   
	   # I/O handle translation.
	   $line = parseIOs($line);
	   
	   # Operator translations which can occur anywhere at any time.
	   $line = parseOperators($line);
      
      # Translate Perl variables.
      $line = checkAndOrTranslateVaribales($line);
		
		# Apply final casting prediction.
      applyTypeCasting($line);
      
		push(@translatedCode, $line);
	} 
	elsif($line =~ m/^\s*\{\s*|^(\s*)\}\s*/)
	{
	   # Detected curly bracket.
	   
	   $spaces = $1;
	   
	   # Process curly brackets.
      $line = parseCurlyBrackets($line, $spaces);
      
      push(@translatedCode, $line) if($line ne "");
	}
	else 
	{
	
		# Lines that can't be translated are turned into comments.
		push(@translatedCode, "# Could not translate: \"".$line."\"\n");
		
	} 
	
}


# Print out translated code.
foreach $line (@translatedCode)
{
   print $line;
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
      $inputLine =~ s/(\s+)\((.+?)\)/$1[$2]/g;
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
   
   # If alternate comma notation exists, remove and recursivly call function again.
	if($line =~ m/(^\s*print\s*.*?)[\'\"]?\,\s*[\'\"]?.*?/)
	{  
	   # Special Case: Function within print statement.
	   $line =~ s/(\))\,\s*[\'\"].+[\'\"]/$1/g;
	   
	   # Remove all quoations on LHS and comma.
	   $line =~ s/[\'\"]\,\s*([a-zA-Z0-9_\$\@])/$1/g;
	   
	   # Remove all quotations on RHS and comma.
	   $line =~ s/([a-zA-Z0-9_\$\@])\,\s*[\'\"].+[\'\"]/$1/g;
	   
	   # Special case, two variables. Remove comma only.
	   $line =~ s/([a-zA-Z0-9_])\,\s*([\$\@])/$1$2/g;
	   
	   # Case: Two strings, Remove quotations on either side.
	   $line =~ s/[\'\"]\,\s*[\'\"]//g;
	   
	   $newSubPart = parsePrint($line);
	   	      
	   $result = $newSubPart;
   }
   elsif($line =~ /^(\s*)print\s*\(?"(.*)\\n+"\)?[\s;]*$/)
   {  
      # Print statement with newline.
      
	   # Get sub part inside print statement.
	   
      # Process inner strings and varibles.
      $newSubPart = translatePrintSubPartVer1($2);
      
	   # Python's print adds a new-line character by default
	   # so we need to delete it from the Perl print statement.
	   $result = $1."print ".$newSubPart."\n";
   }
   elsif($line =~ /^(\s*)print\s*\(?"(.*)"\)?[\s;]*$/)
   {  
      # Print statement without newline.
      
	   # Get sub part inside print statement.
	   
      # Process inner strings and varibles.
      $newSubPart = translatePrintSubPartVer2($2);
      
      # Import required library if already havent done so.
      importSys();
      
	   $result = $1."sys.stdout.write(".$newSubPart.")\n";
   }
   else
   {
      $newSubPart = checkAndOrTranslateVaribales($line);
	      
	   $result = $newSubPart;
   }
   
   return $result;
}

# Function which translates the sub parts of a 'print' statement with new line ##########
#########################################################################################
sub translatePrintSubPartVer1
{  
   my ($inputLine) = @_;
   my $result = '';
   
   if($inputLine =~ /\s+/)
   {  
      # Case: Multiple words.
     
      # Put quotes around all sub parts of srring.
      $inputLine =~ s/(\s*)([a-zA-Z0-9_\$\:\=\\]+)(\s*)/"$2"/g;
      
      # Put print concatenation symbols.
      $inputLine =~ s/\"\"/", "/g;
      
      # Unquote variables. 
      $inputLine =~ s/\"(\$[a-zA-Z_0-9]+)\"/$1/g;
   
      # Laslty, translate any variables.
      $result = checkAndOrTranslateVaribales($inputLine);
   }
   else
   {
      # Case: 1 word.
      if($inputLine =~ /\$/)
      {  
         # Variable.
         $result = checkAndOrTranslateVaribales($inputLine);
      }
      else
      {
         # Not variable.
         $result = "\"$inputLine\"";
      }
   }
   
   return $result;
} 


# Function which translates the sub parts of a 'print' statement without new line #######
#########################################################################################
sub translatePrintSubPartVer2
{  
   my ($inputLine) = @_;
   my $result = '';
   
   if($inputLine =~ /\s+/)
   {  
      # Case: Multiple words.
      
      # Put quotes around all sub parts of srring.
      $inputLine =~ s/(\s*)([a-zA-Z0-9_\$\:\=\\]+)(\s*)/"$2"/g;
      
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
      
      # Remove all uneeded quote markers. '"+"'
      $inputLine =~ s/\"\+\"//g;
   
      # Laslty, translate any variables.
      $result = checkAndOrTranslateVaribales($inputLine);
   }
   else
   {
      # Case: 1 word.
      if($inputLine =~ /\$/)
      {  
         # Variable.
         $result = checkAndOrTranslateVaribales($inputLine);
      }
      else
      {
         # Not variable.
         $result = "\"$inputLine\"";
      }
   }
   
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
   
   # Translate any '$#ARGV'.
   $inputLine =~ s/\$\#ARGV/len(sys.argv) - 1/g;
   
   # Check for short hand list generator '..'
   if($inputLine =~ s/\((.+)\.\.(.+)\)/>>>/g)
   {  
      # Store new start and stop sequence bits.
      $start = $1;
      $stop = $2;
      
      # Complete the shift by 1 if argv detected.
      $start .= " + 1" if($stop =~ m/len\(sys\.argv\)/);
      
      # Add 1 to '$stop'.
      $stop .= " + 1";
      
      # Split where the sequence code should have been.
      @part = split('>>>', $inputLine);
      
      # Insert translation using 'join'.
      $inputLine = join("xrange($start, $stop)", @part);
   }
   
   # Translate any '$#ARGV'.
   $inputLine =~ s/\$\#ARGV/len(sys.argv) - 1/g;
   
   # Short hand increment.
   $inputLine =~ s/\+\+/ += 1/g;
   
   # Short hand decrement.
   $inputLine =~ s/\-\-/ -= 1/g;
   
   # Regular expressions.
   if($inputLine =~ /\s*\$.+?\s+\=\~\s*\/.+\/\;/)
   {
      # Translate line.
      $inputLine =~ s/(\s*)\$(.+?)(\s+)\=\~\s*\/(.+)\/\;/$1$2$3= re.search('$4', $2)/g;
      
      # Import 'Re' library.
      importRE();
   }
   elsif($inputLine =~ /\s*\$.+?\s+\=\~\s*s\/.+\/.*?\/[gi]*\;/)
   {
      # Translate line.
      $inputLine =~ s/(\s*)\$(.+?)(\s+)\=\~\s*s\/(.+)\/(.*?)\/[gi]*\;/$1$2$3= re.sub(r'$4', '$5', $2)/g;
      
      # Import 'RE' library.
      importRE();
   }
   
   return $inputLine;
}

# Function which translates perl control structures #####################################
#########################################################################################
sub parseControlStructures
{
   my ($inputLine) = @_;
   
   if($inputLine =~ m/^(\s*if|\s*while)\s*\((.*?)\)\s*\{?/)
   {   
      # Translate 'if' or 'while'.      
      $inputLine = $1." ".$2.":\n";
   }
   elsif($inputLine =~ m/^(\s*)\}?\]?\s*elsif\s*\((.*?)\)\s*\{?\[?/)
   {
      # Translate 'elsif'.
      $inputLine = $1."elif ".$2.":\n";
   }
   elsif($inputLine =~ m/^(\s*)\}?\]?\s*else\s*\[?\{?/)
   {  
      # Translate 'else'.
      $inputLine = $1."else:\n";
   }
   elsif($inputLine =~ m/^(\s*)foreach\s+([a-zA-Z0-9_]+)\s+(.+)\s+\[/)
   {  
      # Translate 'foreach'.
      $spaces = $1;
      $iterator = $2;
      $listPart = $3;
      
      # Remove outer brackets.
      $listPart =~ s/^\((.+)\)$/$1/g;
      
      # Note: already halve translated at this point. Just to correct the control structure. 
      $inputLine = $spaces."for ".$iterator." in ".$listPart.":\n";
      
   }
   elsif($inputLine =~ m/^(\s*)for\s*\((.*?)\;(.*?)\;(.*?)\)\s*\{?/)
   {  
      # Translate parts of 'for' loop into 'while' loop.
      $spaces = $1;
      $loopVariable = $2;
      $loopCondition = $3;
      $loopIncrementor = $4;
      
      # Save loop incrementor until loop closing brace is detected (same indent of spaces).
      push(@loopEndSpaces, $spaces);
      push(@loopEndIncrementors, $loopIncrementor);
      
      # Concatinate result t return.
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
	   if(@loopEndSpaces || @loopEndIncrementors)
	   {
	      # Checking to see if curly bracket belongs to end of loop construct.
	      # match based on spaces/indents.
	      if($spaces eq $loopEndSpaces[$#loopEndSpaces])
	      {  
	         # Get incrementors and spaces and pop from array.
	         $savedSpaces = pop(@loopEndSpaces);
	         $savedIncrementor = pop(@loopEndIncrementors);
	         
	         $result = "   ".$savedSpaces.$savedIncrementor."\n";
	      }
	   }
	}
	
	return $result;   
}

# Function which translates Perl I/O handles ############################################
#########################################################################################
sub parseIOs
{  
   my ($inputLine) = @_;
   my $result = "";
   
   # Translating the '<>' handle inside while loop.
   if($inputLine =~ s/^(\s*)while\s*\(?\$(.+?)\s*=\s*\<\>\)?\s*\{?/$1for $2 in fileinput.input():/g)
   {
      # Import 'fileinput'.
      importFileInput();
   }
 
   # Translating the '<STDIN>' handle inside while loop.
   if($inputLine =~ s/^(\s*)while\s*\(?\$(.+?)\s*=\s*\<STDIN>\)?\s*\{?/$1for $2 in sys.stdin:/g)
   {
      # Import 'fileinput'.
      importSys();
   }
   
   # Check/Translate STDIN handle .  
   if($inputLine =~ s/\<STDIN\>\s*/sys.stdin.readline()/g)
   {  
      # Import 'sys'.
      importSys();
   }
   
   # Check/Translate ARGV statements. 
   if($inputLine =~ s/\$ARGV\[(.+?)\]/sys.argv[$1]/g)
   {  
      # Import 'sys'.
      importSys();
   }
   elsif($inputLine =~ s/(\s*)\@ARGV(\s*)/$1sys.argv[1:]$2/g)
   {  
      # Import 'sys'.
      importSys();
   }
   
   $result = $inputLine;
	
	return $result;   
}

# Function which translates Perl functions into Python functions ########################
#########################################################################################
sub parseFunctions
{  
   my ($inputLine) = @_;
   my $result = "";
   
   # Translate if exists, the 'chomp' function.
   $inputLine =~ s/(\s*)chomp\s*\(?\s*\$([a-zA-Z0-9_]+)\s*\)?\s*\;/$1$2 = $2.rstrip()/ig;  
   
   # Translate if exists, the 'join' function.
   $inputLine =~ s/join\(?([\'\"].+?[\'\"])\,\s*(.+?)\)/$1.join($2)/;
   
   # Translate if exists, the 'split' function.
   $inputLine =~ s/split\(?([\'\"].+?[\'\"])\,\s*(\$[a-zA-Z0-9_]+)\)?/$2.split($1)/;
   
   $result = $inputLine;
	
	return $result;   
}

# Function which imports 'sys' library and checks if it already imported ################
#########################################################################################
sub importSys
{  
   # Check that flag hasn't been previously used.
   if(!$importSysFlag)
   {
      if($importFileInputFlag || $importREFlag)
      {
         # Other imports exist.
         
         # Remove currrent 'import' line's new line.
         chomp($translatedCode[$lastSheBangLineNum+1]);
         
         # Append new library to line.
         $translatedCode[$lastSheBangLineNum+1] .= ", sys\n";
      }
      else
      {
         # No other imports exist.
         
         # Import required Python library, below hashbang (In array).
         splice(@translatedCode, ($lastSheBangLineNum+1), 0, ("import sys\n")); 
      }
      
      # Check flag so that sys is not imported again.
      $importSysFlag = 1;
         
   }
}

# Function which imports 'fileinput' library and checks if it already imported ##########
#########################################################################################
sub importFileInput
{  
   # Check that flag hasn't been previously used.
   if(!$importFileInputFlag)
   {
      if($importSysFlag || $importREFlag)
      {
         # Other imports exist.
         
         # Remove currrent 'import' line's new line.
         chomp($translatedCode[$lastSheBangLineNum+1]);
         
         # Append new library to line.
         $translatedCode[$lastSheBangLineNum+1] .= ", fileinput\n";
      }
      else
      {
         # No other imports exist.
         
         # Import required Python library, below hashbang (In array).
         splice(@translatedCode, ($lastSheBangLineNum+1), 0, ("import fileinput\n")); 
      }
      
      # Check flag so that sys is not imported again.
      $importFileInputFlag = 1;
         
   }
}

# Function which imports 'RE' library and checks if it already imported #################
#########################################################################################
sub importRE
{  
   # Check that flag hasn't been previously used.
   if(!$importREFlag)
   {
      if($importSysFlag || $importFileInputFlag)
      {
         # Other imports exist.
         
         # Remove currrent 'import' line's new line.
         chomp($translatedCode[$lastSheBangLineNum+1]);
         
         # Append new library to line.
         $translatedCode[$lastSheBangLineNum+1] .= ", re\n";
      }
      else
      {
         # No other imports exist.
         
         # Import required Python library, below hashbang (In array).
         splice(@translatedCode, ($lastSheBangLineNum+1), 0, ("import re\n")); 
      }
      
      # Check flag so that sys is not imported again.
      $importREFlag = 1;
         
   }
}

# Function which checks final translation and looks to insert type casting ##############
#########################################################################################
sub applyTypeCasting
{  
   my ($inputLine) = @_;
   
   
   if($inputLine =~ /^\s*([a-zA-Z_0-9]+)\s*\=\s*(sys\.stdin\.readline\(\))\s*$/)
   {
      if(!exists $variableTypeStore{"$1"})
      {
         # Detected potential type cast.
         $variableTypeStore{"$1"} = $#translatedCode+1;  
      }
   }
   elsif($inputLine =~ /\s*([a-zA-Z_0-9]+)\s*[\=\>\<\!]+\s*[a-zA-Z\'\"\.\(\)]/)
   {
      # Do nothing.
   }
   elsif($inputLine =~ /\s*([a-zA-Z_0-9]+)\s*[\=\>\<\!]+/)
   {
      if(exists $variableTypeStore{"$1"})
      { 
         my $varId = $1;
         my $lineNum = $variableTypeStore{"$varId"};
         
         $lineToModify = $translatedCode[$lineNum];
         
         $lineToModify =~ s/(\s*[a-zA-Z_0-9]+\s*\=\s*)(.+)/$1float($2)/;
         
         $translatedCode[$lineNum] = $lineToModify;
         
            
         delete $variableTypeStore{"$varId"};
        
      }
   }
   
}













