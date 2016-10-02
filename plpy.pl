#!/usr/bin/perl -w
 
# Written by William Fan, z5059967@ad.unsw.edu.au September 2016
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/plpy/

@final = ();
@imports = ();

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
	$line = specialloops($line);
	$line = arguments($line);
	$line = joins($line);
	$line = exits($line);
	$line = regex($line);
	$line = forloops($line);
	$line = ifelse($line);
	$line = comments($line);
	$line = printing($line);
	$line = operator($line);
	$line = variables($line);
	$line = skips($line);
	$line = semicolons($line);
	$line = braces($line);
	#$line = unknown($line);
	if ($line ne 0) {	 #delete line if zero
		push @final, $line;
	}
	
}

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

unshift @final, "#!/usr/local/bin/python3.5 -u";	#add import statements

foreach $arg (@final) {
	print "$arg\n";
}

sub header {	# translate #! line 
	if ($_[0] =~ m/^#!/ && $. == 1) {
		#push @imports, "#!/usr/local/bin/python3.5 -u";
		$_[0] = 0;
	}
	return $_[0];
}

sub strip {
	if ($_[0] =~ /chomp (.*);/) {
		$_[0] =~ s/chomp (.*);/$1 = $1.rstrip()/;
	}
	return $_[0];

}

sub stdin {
	if ($_[0] =~ /\@ARGV/) {
		$_[0] =~ s/\@ARGV/sys.argv[1:]/;
		imports("sys");
	} 
	return $_[0];
}

sub specialloops {
	if ($_[0] =~ /while\s*\((.*)\s*=\s*<>\)\s*{$/) {
		$_[0] =~ s/while\s*\((.*)\s*=\s*<>\)\s*{$/for $1 in fileinput.input\(\):/;	
		imports("fileinput");
	}
	elsif ($_[0] =~ /while\s*\((.*)\s*=\s*<STDIN>\)\s*{$/) {
		$_[0] =~ s/while\s*\((.*)\s*=\s*<STDIN>\)\s*{$/for $1 in sys.stdin\(\):/;	#add extra space
		imports("fileinput");
	}
	return $_[0];
}

sub arguments {
	if ($_[0] =~ /<STDIN>/) {
		$_[0] =~ s/<STDIN>/sys.stdin.readline()/;
		imports("sys");
	}
	return $_[0];
}

sub joins {
	if ($_[0] =~ /join\s*\((.*)\,\s*(.*)\)/) {
		$_[0] =~ s/join\s*\((.*)\,\s*(.*)\)/$1.join\($2\)/;
		imports("sys");
	}
	elsif ($_[0] =~ /join\s*(.*)\,\s*(.*)[;\s*]/) {
		$_[0] =~ s/join\s*(.*)\,\s*(.*)[;\s*]/$1.join\($2\)/;
		imports("sys");
	}
	return $_[0];
}

sub exits {
	if ($_[0] =~ /exit [^\s]+[\s;]+/) {
		$_[0] =~ s/exit (.*)[\s;]+/sys.exit($1)/;		#captures all words after exit right now
		imports("sys");
	}
	return $_[0];
}

sub regex {
	if ($_[0] =~ /=~\s*s\/(.*)\/(.*)\/(.*);/) {
		$_[0] =~ s/=~\s*s\/(.*)\/(.*)\/(.*);/= re.sub(r'$1', '$2', line)/;
		imports("re");
	}
	return $_[0];
}

sub forloops {
	if ($_[0] =~ /for\s*\((.*);\s*(.*);\s*(.*)\)\s*{$/) {
		$_[0] =~ s/for\s*\((.*);\s*(.*);\s*(.*)\)\s*{$/for $1 in $2:/;		#TODO 
	}
	elsif ($_[0] =~ /foreach \$(.*) \([0-9]..[0-9]\)\s*{$/) {
		$_[0] =~ /foreach \$(.*) \((.*)\.\.(.*)\)\s*{$/;
		$tempnumber = $3;
		$tempnumber++;
		$_[0] =~ s/foreach \$(.*) \((.*)\.\.(.*)\)\s*{$/for $1 in range($2, $tempnumber):/;
	}	
	elsif ($_[0] =~ /foreach (.*) \(0\.\.\$#ARGV\)\s*{$/) {
		$_[0] =~ s/foreach (.*) \(0\.\.\$#ARGV\)\s*{$/for $1 in range(len(sys.argv) - 1):/;
		imports("sys");
	}
	elsif ($_[0] =~ /foreach \$(.*) \((.*)\)\s*{$/) {
		$_[0] =~ s/foreach \$(.*) \((.*)\)\s*{$/for $1 in $2:/;
	}

	return $_[0];					#need range number
}

sub ifelse {
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

sub comments {	# Blank & comment lines can be passed unchanged 
	if ($_[0] =~ /^\s*#/ || $_[0] =~ /^\s*$/) {
	}
	return $_[0];
}

sub printing {   				# Python's print adds a new-line character by default so we need to delete it from the Perl print statement   		 
	if ($_[0] =~ /print\s*"\$ARGV\[(.*)\]\\n";$/) {
		$_[0] =~ s/print\s*"\$ARGV\[(.*)\]\\n";$/print(sys.argv[$1 + 1])/;
		imports("sys");
	}
	elsif ($_[0] =~ /^\s*print\s*"(\$.*)\\n"[\s;]*$/) {		#remove quotes when print variables
		$_[0] =~ s/print\s*"(\$.*)\\n"[\s;]*$/print($1)/;
	}
	elsif ($_[0] =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) {	#printing without variables
		$_[0] =~ s/print\s*"(.*)\\n"[\s;]*$/print(\"$1\")/;			 
	}
	elsif ($_[0] =~ /^\s*print\s*(.*),\s*"\\n";*$/) {	#when printing without quotes
		$_[0] =~ s/print\s*(.*),\s*"\\n";*$/print($1)/;
	}
	return $_[0];
}

sub operator {
	if ($_[0] =~ /\+\+/) {
		$_[0] =~ s/\+\+/ \+= 1/g;
	}
	return $_[0];
}
sub variables {
	if ($_[0] =~ /\$(.*)/) {	#converts all $ right now
		$_[0] =~ s/\$//g;
	}
	return $_[0];
}

sub skips {
	if ($_[0] =~ /last;$/) {
		$_[0] =~ s/last;$/break/;
	}
	return $_[0];
}

sub semicolons {
	if ($_[0] =~ /.*;$/) {	
		$_[0] =~ s/;$//;
	}
	return $_[0];
}

sub braces {	#replaces braces with colons
	if ($_[0] =~ /\((.*) eq (.*)\)\s*{$/) {
		$_[0] =~ s/\((.*) eq (.*)\)\s*{$/$1 == $2:/;
	}
	elsif ($_[0] =~ /\((.*) ne (.*)\)\s*{$/) {
		$_[0] =~ s/\((.*) ne (.*)\)\s*{$/$1 != $2:/;
	}
	elsif ($_[0] =~ /\((.*)\)\s*{$/) {
		$_[0] =~ s/\((.*)\)\s*{$/$1:/;	#replaces parentheses in conditionals #maybe replace for advanced 
	} 
	if 	($_[0] =~ /}\s*$/) {
		$_[0] = 0;
	}
	return $_[0];
}

sub imports { #check if already imported
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

sub unknown {	# Lines we can't translate are turned into comments
	return $_[0];
}
