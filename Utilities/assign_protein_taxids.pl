#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;

my $acc2taxid_map_file = shift;

open MAP, "<", $acc2taxid_map_file
  or die "can't read map $acc2taxid_map_file: $!\n";
my %acc2taxid_map;
while (<MAP>) {
  chomp;
  my ($acc, $taxid) = split;
  $acc2taxid_map{$acc} = $taxid;
}
close MAP;

my $printing_sequence = 0;
while (<>) {
  if (/^>/) {
    $printing_sequence = 0;
    my $acc = basename($ARGV, ".faa");
    if (exists $acc2taxid_map{$acc}) {
      my $taxid = $acc2taxid_map{$acc};
      s/\|\s/|kraken:taxid|$taxid| /;
      $printing_sequence = 1;
    }
  }
  print if $printing_sequence;
}
