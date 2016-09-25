#!/usr/bin/perl -w
 
# Written by William Fan, z5059967@ad.unsw.edu.au September 2016
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/plpy/

@final = ();

if (scalar @ARGV == 0){
	open(F,"-");
} else {
	open (F, "<", "$ARGV[0]") or die "$0: can't open $ARGV[0]: $!\n";
}

while ($line = <F>) {
	chomp ($line);
	$line = header($line);
	$line = comments($line);
	$line = printing($line);
	$line = variables($line);
	$line = semicolons($line);
	$line = braces($line);
	#$line = unknown($line);
	if ($line ne ""){
		push @final, $line;
	}
}

foreach $arg (@final){
	print "$arg\n";
}

sub header {	# translate #! line 
	if ($_[0] =~ m/^#!/ && $. == 1) {
		$_[0] = "#!/usr/local/bin/python3.5 -u"
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

sub semicolons {
	if ($_[0] =~ /.*;$/){	#converts all $ right now
		$_[0] =~ s/;$//;
	}
	return $_[0];
}

sub braces {	#might switch to handle specific loops.
	if ($_[0] =~ /\s*{$/){
		$_[0] =~ s/\s*{$/:/;
	}
	if 	($_[0] =~ /}$/){
		$_[0] =~ s/}$//;
	}
	return $_[0];
}

sub unknown {	# Lines we can't translate are turned into comments
	return $_[0];
}
