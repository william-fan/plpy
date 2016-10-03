#!/usr/bin/perl -w

@array=();
while ($a = <>) {
    unshift @array, $a;
}
print reverse @array;
print @array;