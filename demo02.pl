#!/usr/bin/perl -w
#based on devowel from assignment examples

@array=();
while ($a = <>) {
    chomp $a;
    $a =~ s/[aeiou]//g;
    print "$a\n";
    push @array, $a;
}

foreach $arg (@array) {
    if ($arg eq "tst tst") {
        print "hello\n";
    } elsif ($arg eq "") {
        print "empty string\n";
    } else {
        print "no vowel\n";
    }
}