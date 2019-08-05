#!/usr/bin/perl

# Divides input multi-fasta file into single-fasta files, all
# in current directory

use strict;
use warnings;

my $outfile = "single_X.fna";
my $count = 0;

while (<>) {
  if (/^>/) {
    $count++;
    my $file = $outfile;
    $file =~ s/X/$count/;
    open OUT, ">", $file
      or die "can't write $file: $!\n";
  }
  print OUT;
}
