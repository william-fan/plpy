#!/usr/bin/perl -w
 
# Written by William Fan, z5059967@ad.unsw.edu.au September 2016
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/plpy/

@final = ();	#final output
@imports = ();	#import statements
@declare = ();	#declarations, e.g hash tables

#Open input
#Can be possibly changed for multiple files
if (scalar @ARGV == 0) {
	open(F,"-");
} else {
	open (F, "<", "$ARGV[0]") or die "$0: can't open $ARGV[0]: $!\n";
}

while ($line = <F>) {
	chomp ($line);
	$line = header($line);
	$line = strip($line);
	$line = stdin($line);
	$line = specialLoops($line);
	$line = arguments($line);
	$line = strings($line);
	$line = joinSplit($line);
	$line = exits($line);
	$line = regex($line);
	$line = arrayElements($line);
	$line = arrays($line);
	$line = hashTables($line);
	$line = forLoops($line);
	$line = ifElse($line);
	$line = comments($line);
	$line = printing($line);
	$line = operator($line);
	$line = variables($line);
	$line = skips($line);
	$line = semicolons($line);
	$line = braces($line);
	if ($line ne 0) {	 #Check whether to delete line or not
		push @final, $line;
	}

}

unshift	@final, @declare;

#Adds import statements on the same line
if (@imports) {
	$importstring = "import";
	for($count = 0; $count != scalar @imports; $count++) {
		if ($count+1 != scalar @imports) {
			$importstring .= " $imports[$count],";
		}
		else {
			$importstring .= " $imports[$count]"
		}
	}
	unshift	@final, $importstring;
}

unshift @final, "#!/usr/local/bin/python3.5 -u";

#Prints output
foreach $arg (@final) {
	print "$arg\n";
}

#Delete #! line, as we add it in at the end
sub header {	
	if ($_[0] =~ m/^#!/ && $. == 1) {
		$_[0] = 0;
	}
	return $_[0];
}

#Translate chomp to strip
sub strip {
	if ($_[0] =~ /chomp\s*([^\s;]+);*/) {
		$_[0] =~ s/chomp\s*([^\s;]+);*/$1 = $1.rstrip()/;
	}
	return $_[0];

}

#Translate @ARGV
sub stdin {
	if ($_[0] =~ /\@ARGV/) {
		$_[0] =~ s/\@ARGV/sys.argv[1:]/;
		imports("sys");
	} 
	return $_[0];
}

#Translate input loops
sub specialLoops {
	if ($_[0] =~ /while\s*\((.*)\s*=\s*<>\)\s*{$/) {
		$_[0] =~ s/while\s*\(([^\s*]+)\s*=\s*<>\)\s*{$/for $1 in fileinput.input\(\):/;
		imports("fileinput");
	}
    elsif ($_[0] =~ /while\s*\(\s*<>\s*\)\s*{$/) {
		$_[0] =~ s/while\s*\(\s*<>\s*\)\s*{$/for line in fileinput.input\(\):/;
		imports("fileinput");
    }
	elsif ($_[0] =~ /while\s*\((.*)\s*=\s*<STDIN>\)\s*{$/) {
		$_[0] =~ s/while\s*\(([^\s*]+)\s*=\s*<STDIN>\)\s*{$/for $1 in sys.stdin\(\):/;	
		imports("sys");
	}
	return $_[0];
}

#Translate stdin
sub arguments {
	if ($_[0] =~ /\$(.*)\s*\=\s*\<STDIN\>\;/) {
		$_[0] =~ s/\$([^\s*]+)\s*\=\s*\<STDIN\>\;/$1 = sys.stdin.readline\(\)/;
		imports("sys");
	}
	elsif ($_[0] =~ /<STDIN>/) {
		$_[0] =~ s/<STDIN>/sys.stdin.readline()/;
		imports("sys");
	}
	return $_[0];
}

#Translate string concatenation operators
sub strings {
	if ($_[0] =~ /\$([^\s*]+)\s*\.\s*\$(.*)/) {
		$_[0] =~ s/\$([^\s*]+)\s*\.\s*\$(.*)/\$$1 + \$$2/;
	}
	if ($_[0] =~ /\$([^\s*]+)\s*\.=\s*\$(.*)/) {
		$_[0] =~ s/\$([^\s*]+)\s*\.=\s*\$(.*)/\$$1 += \$$2/;
	}
	return $_[0];
}	

#Translate join and split
sub joinSplit {
	if ($_[0] =~ /join\s*\((.*)\,\s*(.*)\);*/) {
		$_[0] =~ s/join\s*\((.*)\,\s*(.*)\);*/$1.join\($2\)/;
	}
	elsif ($_[0] =~ /join\s*(.*)\,\s*(.*)[;\s*];*/) {
		$_[0] =~ s/join\s*(.*)\,\s*(.*)[;\s*];*/$1.join\($2\)/;
	}
	if ($_[0] =~ /split\s*\(\/(.*)\/\,\s*\$(.*)\);*/) {
		$_[0] =~ s/split\s*\(\/(.*)\/\,\s*\$(.*)\);*/re\.split\(r'$1', $2\)/;
		imports("re");
	}
	return $_[0];
}

#Translates exit, keeping the same error code
#Error code should not impact much
sub exits {
	if ($_[0] =~ /exit [^\s]+/) {
		$_[0] =~ s/exit ([^\s*]+)/sys.exit($1)/;
		imports("sys");
	}
	return $_[0];
}

#Translates regex to python equivalent
sub regex {
	if ($_[0] =~ /\$([^\s*]+)\s*=~\s*s\/(.*)\/(.*)\/(.*);*/) {
		$_[0] =~ s/\$([^\s*]+)\s*=~\s*s\/(.*)\/(.*)\/(.*);*/$1 = re.sub(r'$2', '$3', $1)/;
		imports("re");
	}
	elsif ($_[0] =~ /\$([^\s*]+)\s*=~\s*\/(.*)\/;*/) {
		$_[0] =~ s/\$([^\s*]+)\s*=~\s*\/(.*)\/;*/$1 = re.match(r'$2', $1)/;
		imports("re");
	}
	return $_[0];
}

#Translates array operations, such as push and pop
sub arrayElements {
	if ($_[0] =~ /push\s*@(.*),\s*([^\s;]+)/) {
		$_[0] =~ s/push\s*@(.*),\s*([^\s;]+)/$1.append($2)/;
	}
	if ($_[0] =~ /pop\s*@([^\s;]+)/) {
		$_[0] =~ s/pop\s*@([^\s;]+)/$1.pop()/;
	}
	if ($_[0] =~ /unshift\s*@(.*),\s*([^\s;]+);*/) {
		$_[0] =~ s/unshift\s*@(.*),\s*([^\s;]+);*/$1.insert(0, $2)/;
	}
	if ($_[0] =~ /shift\s*@([^\s;]+);*/) {
		$_[0] =~ s/shift\s+@([^\s;]+);*/$1.pop(0)/;
	}
    if ($_[0] =~ /(.*)\s*=\s*reverse\s*@([^\s;]+);*/) {
        $_[0] =~ s/(.*)\s*=\s*reverse\s*@([^\s;]+);*/$2.reverse()/;
    }
	elsif ($_[0] =~ /reverse\s*@([^\s;]+);*/) {
		$_[0] =~ s/reverse\s*@([^\s;]+);*/$1.reverse()/;
	}
	return $_[0];
}

#Translates array declarations
sub arrays {
	if ($_[0] =~ /@([^\s*]+)\s*=\s*\((.*)\);/) {
		$_[0] =~ s/@([^\s*]+)\s*=\s*\((.*)\);/$1 = [$2]/;
	}
	if ($_[0] =~ /@(.*)/) {
		$_[0] =~ s/@(.*)/$1/;
	}
	return $_[0];
}

#Translates hash table declarations, adds declaration to the beginning of the file
sub hashTables {
	if ($_[0] =~ /\$(.*)\{(.*)\}/) {
		$_[0] =~ s/\$(.*)\{(.*)\}/$1\[$2\]/;
		declarations("$1 = {}")
	}
	elsif ($_[0] =~ /\%([^\s*]+)\s*=\s*\(\);$/) {
		$_[0] = 0;
		declarations("$1 = {}")
	}
	return $_[0];
}

#Translates certain for loops
#Does not translate all styles
sub forLoops {
    #Convert c style for loop
	#Only matchs < inside for loop
	if ($_[0] =~ /for\s*\(\s*\$([^\s*]+)\s*=\s*([0-9]+);\s*\$([^\s*]+)\s*<\s*([0-9]+);\s*(.*)\)\s*{$/) {
		if ($5 =~ /\+\+/) {
			$tempnumber = "1";
		} 
		else {
			$tempnumber = $5;		#store increment size
			$tempnumber =~ s/\s*(.*)+=\s*//;
		}
		$_[0] =~ s/for\s*\(
		\s*\$([^\s*]+)\s*=\s*([0-9]+);	#store variable name and number
		\s*\$([^\s*]+)\s*<\s*([0-9]+);	#store < number
		\s*(.*)\)\s*{$					#replace increment with tempnumber
		/for $1 in range($2, $4, $tempnumber):/x;
	}
    #Convert foreach loop with a range
	elsif ($_[0] =~ /foreach \$(.*) \([0-9]..[0-9]\)\s*{$/) {
		$_[0] =~ /foreach \$(.*) \((.*)\.\.(.*)\)\s*{$/;
		$tempnumber = $3;
		$tempnumber++;
		$_[0] =~ s/foreach \$(.*) \((.*)\.\.(.*)\)\s*{$/for $1 in range($2, $tempnumber):/;
	}
    #Convert specific $ARGV loop
	elsif ($_[0] =~ /foreach (.*) \(0\.\.\$#ARGV\)\s*{$/) {
		$_[0] =~ s/foreach (.*) \(0\.\.\$#ARGV\)\s*{$/for $1 in range(len(sys.argv) - 1):/;
		imports("sys");
	}
    #Convert general for each loop
	elsif ($_[0] =~ /foreach \$(.*) \((.*)\)\s*{$/) {
		$_[0] =~ s/foreach \$(.*) \((.*)\)\s*{$/for $1 in $2:/;
	}
	return $_[0];
}

#Translates elsifs, elses
sub ifElse {
	if ($_[0] =~ /}\s*elsif/) {
		$_[0] =~ s/}\s*elsif/elif/;		
	}
	elsif ($_[0] =~ /elsif/) {
		$_[0] =~ s/elsif/elif/;	
	}
	if ($_[0] =~ /}\s*else\s*{/) {
		$_[0] =~ s/}\s*else\s*{/else:/;		
	}
	elsif ($_[0] =~ /else\s*{/) {
		$_[0] =~ s/else\s*{/else:/;	
	}
	return $_[0];
}

#Leave comments unchanged
sub comments {
	if ($_[0] =~ /^\s*#/ || $_[0] =~ /^\s*$/) {
	}
	return $_[0];
}

#Translates print statements
sub printing {
	if ($_[0] =~ /\s*print\s*"\$ARGV\[(.*)\]\\n";$/) {   #Translate $ARGV  
		$_[0] =~ s/print\s*"\$ARGV\[(.*)\]\\n";$/print(sys.argv[$1 + 1])/;
		imports("sys");
	}
	elsif ($_[0] =~ /\s*print\s*"(\$.*)( .*)\\n"[\s;]*$/) {   #When inserting variables into prints 
		$_[0] =~ s/print\s*"(\$.*)( .*)\\n"[\s;]*$/print("%s$2" % $1)/;
	}
	elsif ($_[0] =~ /\s*print\s*"(\$.*)\\n"[\s;]*$/) {		#Remove quotes when printing variables
		$_[0] =~ s/print\s*"(\$.*)\\n"([\s;])*$/print($1)/;
	}
	elsif ($_[0] =~ /\s*print\s*"(.*)\\n"[\s;]*$/) {	#Printing without variables
		$_[0] =~ s/print\s*"(.*)\\n"([\s;])*$/print(\"$1\")/;
	}
	elsif ($_[0] =~ /\s*print\s*(.*),\s*"\\n";*$/) {	#Printing without quotes
		$_[0] =~ s/print\s*(.*),\s*"\\n";*$/print($1)/;
	}
	elsif ($_[0] =~ /\s*print\s*"(.*)"/) {   #Printing without newlines
		$_[0] =~ s/print\s*"(.*)"/sys.stdout.write("$1")/;
		imports("sys");
	}
	return $_[0];
}

#Translate ++, -- operators
sub operator {
	if ($_[0] =~ /\+\+/) {
		$_[0] =~ s/\+\+/ \+= 1/g;
	}
	if ($_[0] =~ /\-\-/) {
		$_[0] =~ s/\-\-/ \-= 1/g;
	}
	return $_[0];
}

#Remove $ sign for variables
#Converts all $ right now
sub variables {
	if ($_[0] =~ /\$(.*)/) {
		$_[0] =~ s/\$//g;
	}
	return $_[0];
}

#Translate lasts
sub skips {
	if ($_[0] =~ /last;$/) {
		$_[0] =~ s/last;$/break/;
	}
	return $_[0];
}

#Remove semicolons at the end of lines
sub semicolons {
	if ($_[0] =~ /.*;$/) {	
		$_[0] =~ s/;$//;
	}
	return $_[0];
}

#Replaces braces with colons
sub braces {	
	if ($_[0] =~ /\((.*) eq (.*)\)\s*{$/) {
		$_[0] =~ s/\((.*) eq (.*)\)\s*{$/$1 == $2:/;
	}
	elsif ($_[0] =~ /\((.*) ne (.*)\)\s*{$/) {
		$_[0] =~ s/\((.*) ne (.*)\)\s*{$/$1 != $2:/;
	}
	elsif ($_[0] =~ /\((.*)\)\s*{$/) {
		$_[0] =~ s/\((.*)\)\s*{$/$1:/;	#Replaces parentheses in conditionals in general situation
	} 
	if 	($_[0] =~ /\s*}\s*$/) { #Remove needless end braces
		$_[0] = 0;
	}
	return $_[0];
}

#Check if an import has been added, otherwise add it to the list
sub imports { 
	$temp = 0;
	foreach $arg (@imports) {
		if ($arg eq $_[0]) {
			$temp = 1;
		}
	}
	if ($temp == 0) {
		push @imports, $_[0];
	}
	return;
}

#Check if already declared, otherwise add to list
sub declarations { 
	$temp = 0;
	foreach $arg (@declare) {
		if ($arg eq $_[0]) {
			$temp = 1;
		}
	}
	if ($temp == 0) {
		push @declare, $_[0];
	}
	return;
}
