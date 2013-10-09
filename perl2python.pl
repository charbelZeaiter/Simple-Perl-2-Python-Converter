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
$importCopyFlag = 0;

%variableTypeStore = ();
############################################

# Main Loop: Behave like unix filter and read in all lines.
while ($line = <>)
{
   # Start matching and translating.
   if ($line =~ /^#!/ && $. == 1) 
   {
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
	elsif ($line =~ m/\s*if\s*\(|\s*elsif\s*\(|\s*else\s*\{?|\s*while\s*\(|\s*foreach\s*\(|\s*for\s*/)
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
	elsif ($line =~ /[\$\@\%]|open\(?|close [a-zA-Z0-9_]+/)
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
		chomp($line);
		push(@translatedCode, "# Could not translate: |".$line."|\n");
		
	} 
	
}


# Print out translated code.
foreach $line (@translatedCode)
{
   print $line;
}


# Functions #######################################################################################


# Function which translates variables ###################################################
#########################################################################################
sub checkAndOrTranslateVaribales 
{
   
   my ($inputLine) = @_;

   # Scalers.
   if($inputLine =~ s/\$([a-zA-Z_1-9]+)/$1/g)
   {
      # Translate brackets for hash scalers, if exists.
      $inputLine =~ tr/{}/[]/;
      
      # Cast assignments to int if only numbers in string.
      $inputLine =~ s/(\"[0-9]+\")/int($1)/g;
      
      # Cast assignments to float if decimals only in string.
      $inputLine =~ s/(\"[0-9]+\.[0-9]+\")/float($1)/g;
   }
   
   # Arrays.
   if($inputLine =~ s/\@([a-zA-Z_1-9]+)/$1/g)
   {  
      $varName = $1;
      
      # Translate brackets if exists.
      $inputLine =~ s/$varName\((.+?)\)/[$1]/g;
      
      # Translate brackets if exists.
      $inputLine =~ s/ \((.*?)\)/ [$1]/g;
   }
   
   # Hashes.
   if($inputLine =~ s/\%([a-zA-Z_1-9]+)/$1/g)
   {
      $varName = $1;
      
      # Translate brackets if exists.
      $inputLine =~ s/$varName\{(.+?)\}{(.+?)\}/[$1][$2]/g;
      
      # Translate brackets if exists.
      $inputLine =~ s/$varName\{(.+?)\}/[$1]/g;
      
      # Translate brackets if exists.
      $inputLine =~ s/ \((.*?)\)/ {$1}/g;
      
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
	   # Capture original line in.
	   $originalLine = $line;
	   
	   # Special Case: Function within print statement.
	   $line =~ s/(\))\,\s*[\'\"].+[\'\"]/$1/g;
	   
	   # Remove all quoations on LHS and comma.
	   $line =~ s/[\'\"]\,\s*([a-zA-Z0-9_\$\@])/$1/g;
	   
	   # Remove all quotations on RHS and comma.
	   $line =~ s/([a-zA-Z0-9_\$\}\]\)])\,\s*[\'\"].+[\'\"]/$1/g;
	   
	   # Special case, two variables. Remove comma only.
	   $line =~ s/([a-zA-Z0-9_])\,\s*([\$\@])/$1$2/g;
	   
	   # Case: Two strings, Remove quotations on either side.
	   $line =~ s/[\'\"]\,\s*[\'\"]//g;
	   
	   # Protection against infinit recursion. If no change detected, then return 'cant translate'.
	   if($originalLine eq $line)
	   {
	      chomp($line);
	      $line = "# Could not translate: |".$line."|\n";
	   }
	   else
	   {
	      $line = parsePrint($line);
	   }
	   
	   $result = $line;
	   
   }
   elsif($line =~ /^\s*print\s*([^\+\s]+\+[^\+\s]+)+/)
   {  
      # Print statement that has already been prepared by the operator function.
	   
	   # Remove newline if exists
      if($line =~ s/\\n[\"\']\s*\;?$/";/g)
      {  
         # Remove extra quotes with plus after removed '\n'.
         $line =~ s/\+[\'\"]{2}\s*\;$//g;
	   }
	   else
	   {
	      
	      # If no new line exists nativly, call 'write' method.
	      
	      # Import required library if already havent done so.
         importSys();
         
         # Modify convert 'print' to 'write'.
	      $line =~ s/^(\s*)print\s*\(?/$1sys.stdout.write(/;
	      $line =~ s/\;/)/;
	      
	   }
	   
	   # Translate any variables.
	   $line = checkAndOrTranslateVaribales($line);
	   
	   $result = $line;
   }
   elsif($line =~ /^(\s*)print\s*\(?"(.*)\\n+"\)?[\s;]*$/)
   {  
      # Print statement with newline.
	   
      # Process inner strings and varibles.
      $newSubPart = translatePrintSubPartWithNewline($2);
      
	   # Python's print adds a new-line character by default
	   # so we need to delete it from the Perl print statement.
	   $result = $1."print ".$newSubPart."\n";
   }
   elsif($line =~ m/^(\s*)print\s+([a-zA-Z0-9_]+)\s+[\'\"](.+?)[\'\"]\s*\;/)
   {
      # Check for prints that write out to a file.
      $innerPart = $3;
      $fileHandle = $2;
      $spaces = $1;
      
      # Process inner strings and varibles.
      $newInnerPart = convertSinglePerlOutputString($innerPart);
      
	   $result = $spaces.$fileHandle.".write(".$newInnerPart.")\n";
   }
   elsif($line =~ /^(\s*)print\s*\(?\"(.*?)\"\)?[\s;]*$/)
   {  
      # Print statement without newline.

      # Process inner strings and varibles.
      $newSubPart = translatePrintSubPartWithoutNewline($2);
      
      # Import required library if already havent done so.
      importSys();
      
	   $result = $1."sys.stdout.write(".$newSubPart.")\n";
   }
   elsif($line =~ /^(\s*)print\s*\(?[\$]([a-zA-Z0-9_]+)\)?\s*\;?$/)
   {
      # Detected a single varibale only without a newline.
      
      # Import required library if already havent done so.
      importSys();
      
      $result = $1."sys.stdout.write(str(".$2."))\n";
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
sub translatePrintSubPartWithNewline
{  
   my ($inputLine) = @_;
   my $result = '';
   
   if($inputLine =~ /\s+/)
   {  
      # Case: Multiple words (multiple spaces between them).
      
      # Put quotes around all sub parts of srring.
      $inputLine =~ s/(\s*)([^ ]+)(\s*)/"$2"/g;
      
      # Put print concatenation symbols.
      $inputLine =~ s/\"\"/", "/g;
      
      # Unquote variables. 
      $inputLine =~ s/\"([\$\@][a-zA-Z_0-9]+)\"/$1/g;
      
      # Laslty, translate any variables.
      $result = checkAndOrTranslateVaribales($inputLine);
   }
   else
   {
      # Case: 1 word.
      if($inputLine =~ /[\$\@]/)
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
sub translatePrintSubPartWithoutNewline
{  
   my ($inputLine) = @_;
   my $result = '';
   
   if($inputLine =~ /\s+/)
   {  
      # Case: Multiple words (multiple spaces between them).
      
      # Put quotes around all sub parts of srring.
      $inputLine =~ s/(\s*)([^ ]+)(\s*)/"$2"/g;
      
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
   $inputLine =~ s/use constant ([_a-zA-Z0-9]+) \=\> ([0-9]+)\;/$1 = $2/i or die("Unexpected error in 'parseNumericConstant' function. \n");
   
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
   
   # Short hand increment.
   $inputLine =~ s/\+\+/ += 1/g;
   
   # Short hand decrement.
   $inputLine =~ s/\-\-/ -= 1/g;
   
   # Regular expressions.
   if($inputLine =~ /\s*\$.+?\s+\=\~\s*m?\/.+\/\;?/)
   {  
      # Translate line.
      $inputLine =~ s/(\s*)\$(.+?)(\s+)\=\~\s*\/(.+)\/\;?/$1$2$3= re.search('$4', $2)/g;
      
      # Import 'Re' library.
      importRE();
   }
   elsif($inputLine =~ /\s*\$.+?\s+\=\~\s*s\/.+\/.*?\/[gi]*\;?/)
   {
      # Translate line.
      $inputLine =~ s/(\s*)\$(.+?)(\s+)\=\~\s*s\/(.+)\/(.*?)\/[gi]*\;?/$1$2$3= re.sub(r'$4', '$5', $2)/g;
      
      # Import 'RE' library.
      importRE();
   }
   
   # Translate concatenation '.' to '+'.
   if($inputLine !~ /[a-zA-Z0-9_]\(.*?\)/)
   {
      # Make sure there are no functions, hence parenthesis.

      # With Strings on both sides.
      $inputLine =~ s/([\'\"])\.([\'\"])/$1+$2/g;

      # With variable on both sides.
      $inputLine =~ s/(\$[a-zA-Z_0-9\[\]\{\}]+)\.(\$[a-zA-Z_0-9\[\]\{\}]+)/str($1)+str($2)/g;

      # With String on LHS and variable on RHS.
      $inputLine =~ s/([\'\"])\.(\$[a-zA-Z_0-9\[\]\{\}]+)/$1+str($2)/g;

      # With variable on LHS and String on RHS.
      $inputLine =~ s/(\$[a-zA-Z_0-9\[\]\{\}]+)\.([\'\"])/str($1)+$2/g;

      # Convert left over '.' operators
      $inputLine =~ s/(\)|\'|\")\.(s|\'|\")/$1+$2/g;
      
   }
   
   # Translate '.=' to '+='
   $inputLine =~ s/(\s*)\.\=\s*([^\;]+)/$1+= $2/;   
   
   return $inputLine;
}


# Function which translates perl control structures #####################################
#########################################################################################
sub parseControlStructures
{
   my ($inputLine) = @_;
   
   if($inputLine =~ m/^(\s*if|\s*while)\s*\((.*)\)\s*\{?/)
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
   elsif($inputLine =~ m/^(\s*)foreach\s+([a-zA-Z0-9_]+)\s+(.+)\s+\[?/)
   {  
      # Translate 'foreach'.
      $spaces = $1;
      $iterator = $2;
      $listPart = $3;
      
      # Remove outer brackets.
      $listPart =~ s/^[\[\(](.+)[\)\]]/$1/;
      
      # Remove ending space and bracket.
      $listPart =~ s/\s*\[?$//;
      
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
   
   # Tranlate any left over handles.
   $inputLine =~ s/\s*\<([a-zA-Z0-9_])\>\s*/$1/g;
   
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
   $inputLine =~ s/join\s*\(?([\'\"\/].+?[\'\"\/])\,\s*(.+?)\)/$1.join($2)/;
   
   # Translate if exists, the 'split' function.
   $inputLine =~ s/split\s*\(?([\'\"\/].+?[\'\"\/])\,\s*(\$[a-zA-Z0-9_]+)\)?/$2.split($1)/;
   
   # Translate if exists, the 'push' function with variable.
   $inputLine =~ s/push\(\@([a-zA-Z0-9_]+),\s*([\$\'\"a-zA-Z0-9_]+)\)/$1.append($2)/;
   
   # Translate if exists, the 'push' function with list.
   $inputLine =~ s/push\(\@([a-zA-Z0-9_]+),\s*(\@[a-zA-Z0-9_]+)\)/$1.extend($2)/;
   
   # Translate if exists, the 'pop' function.
   $inputLine =~ s/pop\(\@([a-zA-Z0-9_]+)\)/$1.pop()/;
   
   # Translate if exists, the 'shift' function.
   $inputLine =~ s/shift\(\@([a-zA-Z0-9_]+)\)/$1.pop(0)/;
   
   # Translate if exists, the 'unshift' function with variable.
   $inputLine =~ s/unshift\(\@([a-zA-Z0-9_]+),\s*([\$\'\"a-zA-Z0-9_]+)\)/$1.insert(0, $2)/;
   
   # Translate if exists, the 'unshift' function with list.
   if($inputLine =~ /(\s*)unshift\(\@([a-zA-Z0-9_]+),\s*(\@[a-zA-Z0-9_]+)\)/)
   {
      # Swap references around to perform an equivalant opperation. 
      $inputLine = $1."_temp = ".$2."\n";
      $inputLine .= $1.$2." = ".$3."\n";
      $inputLine .= $1.$2.".extend(_temp)\n";
   }
   
   # Translate if exists, the 'reverse' function.
   if($inputLine =~ /(\s*)\@([a-zA-Z0-9_]+)\s*\=\s*reverse\(\@([a-zA-Z0-9_]+)\)/)
   {  
      if($2 eq $3)
      {  
         # Assignment variable has same name as array to change, so reverse in place.
         $inputLine = $1.$2.".reverse()\n";
      }
      else
      {  
         # Assignment variables name is different to array name, copy array then reverse in new variable.
         $inputLine = $1.$2." = copy.deepcopy(".$3.")\n";
         $inputLine .= $1.$2.".reverse()\n";
         
         # Import 'copy'.
         importCopy();
      }
   }
 
   # Translate 'open' function.
   if($inputLine =~ /^(\s*)open\s*\(?\<?([a-zA-Z0-9_]+)\>?\,\s*[\'\"]([rwa\+\<\>]+)(.+?)[\'\"]\)?\;/)
   {  
      $spaces = $1;
      $fileHandle = $2;
      $accessTypes = $3;
      $file = $4;
      
      # Convert access Types.
      if($accessTypes =~ /\+\>\>|a\+/)
      {
         # '+>>' or 'a+'   Reads, Writes, Appends, and Creates to > 'ab+'.
         $accessTypes = "a+";
      } 
      elsif($accessTypes =~ /\+\>|w\+/)
      {
         # +> or w+ 	Reads, Writes, Creates, and Truncates to > 'w+'.
         $accessTypes = "w+";
      }
      elsif($accessTypes =~ /\+\<|r\+/)
      {
         # +< or r+ 	Reads and Writes to > 'r+'.
         $accessTypes = "r+";
      }
      elsif($accessTypes =~ /\>\>|a/)
      {
         # >> or a 	Writes, Appends, and Creates to > 'a'.
         $accessTypes = "a";
      }
      elsif($accessTypes =~ /\>|w/)
      {
         # > or w 	Creates, Writes, and Truncates to 'w'.
         $accessTypes = "w";
      }
      else
      {
         # < or r 	Read Only Access to 'r'.
         $accessTypes = "r";
      }
      
      # Final translation.
      $inputLine = $spaces.$fileHandle." = open(\"".$file."\", \"".$accessTypes."\")\n";
      
   }
   
   # Translate file handle close function.
   $inputLine =~ s/^(\s*)close\s*([a-zA-Z_0-9]+)\s*/$1$2.close()/;
   
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
      if($importFileInputFlag || $importREFlag || $importCopyFlag)
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
      if($importSysFlag || $importREFlag || $importCopyFlag)
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
      if($importSysFlag || $importFileInputFlag || $importCopyFlag)
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


# Function which imports 'Copy' library and checks if it already imported ###############
#########################################################################################
sub importCopy
{  
   # Check that flag hasn't been previously used.
   if(!$importCopyFlag)
   {
      if($importSysFlag || $importFileInputFlag || $importREFlag)
      {
         # Other imports exist.
         
         # Remove currrent 'import' line's new line.
         chomp($translatedCode[$lastSheBangLineNum+1]);
         
         # Append new library to line.
         $translatedCode[$lastSheBangLineNum+1] .= ", copy\n";
      }
      else
      {
         # No other imports exist.
         
         # Import required Python library, below hashbang (In array).
         splice(@translatedCode, ($lastSheBangLineNum+1), 0, ("import copy\n")); 
      }
      
      # Check flag so that sys is not imported again.
      $importCopyFlag = 1;
         
   }
}


# Function which checks translation for casting before its pushed onto the array ########
#########################################################################################
sub applyTypeCasting
{  
   my ($inputLine) = @_;
   
   if($inputLine =~ /^\s*([a-zA-Z_0-9]+)\s*\=\s*(sys\.stdin\.readline\(\))\s*$/)
   {  
      # Check for input into program.
      
      # If variable for input hasnt been stored, store it for potential type casting.
      if(!exists $variableTypeStore{"$1"})
      {
         # Detected potential type cast.
         $variableTypeStore{"$1"} = $#translatedCode+1;  
      }
   }
   elsif($inputLine =~ /\s*([a-zA-Z_0-9]+)\s*([\+\*\/\%\-0-9]+\s*)*[\=\>\<\!]+(\s*[\+\*\/\%\-0-9]+)+/)
   {  
      # Check later down in the code for explicit variable type use (as an Int, Float etc).
      
      # Detected that variable is used as an Int, Float. 
      
      # If variable was previously saved and is part of input casting.
      if(exists $variableTypeStore{"$1"})
      { 
         my $varId = $1;
         my $lineNum = $variableTypeStore{"$varId"};
         
         # Get input line to cast.
         $lineToModify = $translatedCode[$lineNum];
         
         # Cast line.
         $lineToModify =~ s/(\s*[a-zA-Z_0-9]+\s*\=\s*)(.+)/$1float($2)/;
         
         # Insert new line into translated code.
         $translatedCode[$lineNum] = $lineToModify;
         
         # Delete variable cast reference (to only cast 'input line' once).   
         delete $variableTypeStore{"$varId"};
        
      }
   }
   
}


# Function which translates a single Perl string to a equivalant form in Python #########
#########################################################################################
sub convertSinglePerlOutputString
{  
   my ($inputLine) = @_;
   
   # Put quotes around all sub parts of srring.
   $inputLine =~ s/(\s*)([^ ]+)(\s*)/"$2"/g;
   
   # Insert concatenation symbols and spaces.
   $inputLine =~ s/""/"+" "+"/g;
   
   # Unquote variables & convert them while here. 
   $inputLine =~ s/\"[\$\@]([a-zA-Z_0-9]+)\"/str($1)/g;
   
   return $inputLine
} 










