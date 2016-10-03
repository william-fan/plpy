#!/usr/bin/perl -w

$line = <STDIN>;
chomp $line;
if ($line ne "") {
    $line =~ s/-//;	
    $line =~ s/<\/td>//;
    $line =~ s/<\/a>//;
    $line =~ s/<.*>//;
    $line =~ s/\s+/ /g;
}

print "$line\n";