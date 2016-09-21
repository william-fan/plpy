#!/usr/bin/perl -w
 
# Written by William Fan, z5059967@ad.unsw.edu.au September 2016
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/plpy/

if (scalar @ARGV == 0){
	open(F,"-");
} else {
	open (F, "<", "$ARGV[0]") or die "$0: can't open $ARGV[0]: $!\n";
}

while ($line = <F>) {
	$line = &header($line);
	comments();
	printing();
	unknown();
}

sub header {	# translate #! line 
	if ($_[0] =~ m/^#!/ && $. == 1) {
		$_[0] =~ tr/#/!/;
	}
	return $_[0];
}

sub comments {	# Blank & comment lines can be passed unchanged 
	if ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
	}
	return $_[0];
}

sub printing {   				# Python's print adds a new-line character by default		
	if ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) {
		$line =~ s/^\s*print\s*"(.*)\\n"[\s;]*$/"print(\"\$1\")"/;			# so we need to delete it from the Perl print statement    
	}
	return;
}

sub unknown {	# Lines we can't translate are turned into comments
	$line =~ s/$line/#$line\n/;
	return;
}