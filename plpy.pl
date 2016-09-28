#!/usr/bin/perl -w
 
# Written by William Fan, z5059967@ad.unsw.edu.au September 2016
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/plpy/

@final = ();
@imports = ();

if (scalar @ARGV == 0){
	open(F,"-");
} else {
	open (F, "<", "$ARGV[0]") or die "$0: can't open $ARGV[0]: $!\n";
}

while ($line = <F>) {
	chomp ($line);
	$line = header($line);
	$line = strip($line);
	$line = stdin($line);
	$line = comments($line);
	$line = printing($line);
	$line = variables($line);
	$line = skips($line);
	$line = semicolons($line);
	$line = braces($line);
	#$line = unknown($line);
	if ($line ne ""){
		push @final, $line;
	}
	
}

unshift @final, @imports;

foreach $arg (@final){
	print "$arg\n";
}

sub header {	# translate #! line 
	if ($_[0] =~ m/^#!/ && $. == 1) {
		push @imports, "#!/usr/local/bin/python3.5 -u";
		$_[0] = "";
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
	if ($_[0] =~ /<STDIN>/) {
		$_[0] =~ s/<STDIN>/sys.stdin.readline()/;
		imports("import sys");
	}

	return $_[0];
}

sub comments {	# Blank & comment lines can be passed unchanged 
	if ($_[0] =~ /^\s*#/ || $_[0] =~ /^\s*$/) {
	}
	return $_[0];
}

sub printing {   				# Python's print adds a new-line character by default so we need to delete it from the Perl print statement   		 
	if ($_[0] =~ /^\s*print\s*"(\$.*)\\n"[\s;]*$/){		#remove quotes when print variables
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

sub variables {
	if ($_[0] =~ /\$(.*)/){
		$_[0] =~ s/\$//g;
	}
	return $_[0];
}

sub skips {
	if ($_[0] =~ /last;$/){
		$_[0] =~ s/last;$/break/;
	}
	return $_[0];
}

sub semicolons {
	if ($_[0] =~ /.*;$/){	#converts all $ right now
		$_[0] =~ s/;$//;
	}
	return $_[0];
}

sub braces {	#replaces braces with colons
	if ($_[0] =~ /\((.*) eq (.*)\)\s*{$/){
		$_[0] =~ s/\((.*) eq (.*)\)\s*{$/$1 == $2:/;
	}
	elsif ($_[0] =~ /\((.*)\)\s*{$/){
		$_[0] =~ s/\((.*)\)\s*{$/$1:/;	#replaces parentheses in conditionals #maybe replace for advanced 
	} 
	if 	($_[0] =~ /}$/){
		$_[0] =~ s/}$//;
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
