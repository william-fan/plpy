#!/usr/bin/perl -w

@words = ();

while ($a = <>) {
    chomp $a;
    if ($a eq "tennis") {
        unshift @words, "sport";
    } elsif ($a eq "green") {
        push @words, "color";
    } elsif ($a eq "chair") {
        unshift @words, "furniture";
    } else {
        print "unknown";
    }
}
    
for ($count = 0; $count < 3; $count ++) {
    if ($count == 2) {
        last;
    }
}
print $count;
@words = reverse @words;
print @words;