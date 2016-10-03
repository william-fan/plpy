#!/usr/bin/perl -w

$year = "1:2:3:4:5";
chomp $year;
@hello = split (/:/,$year);
print @hello;
print join ('+', @hello);

foreach $temp (0..4){
    $hello[$temp] .= $hello[$temp]
}

foreach $arg (@hello) {
    print "$arg hello\n";
}