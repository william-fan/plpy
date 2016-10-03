#!/usr/bin/perl -w

$count = 0;
@array=('password', 'temp', 'test');
foreach $arg (@array) {
    $temp = "password";
    if ($arg eq "password") {
        print "bad password\n";
    }
    else {
        print $arg,"\n";
    }
    $count++;
}
print "$count\n";