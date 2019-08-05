#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw/:seek/;

my ($list_file, $gi_taxid_map_file) = @ARGV;

open LIST, "<", $list_file
  or die "can't open list $list_file: $!\n";
my %requested_ginums;
while (<LIST>) {
  /^>gi\|(\d+)/ and $requested_ginums{$1}++;
}
seek LIST, 0, SEEK_SET;

open GI_MAP, "<", $gi_taxid_map_file
  or die "can't open map $gi_taxid_map_file: $!\n";
my %found_taxids;
while (<GI_MAP>) {
  chomp;
  my ($gi, $taxid) = split;
  next unless exists $requested_ginums{$gi};
  $found_taxids{$gi} = $taxid;
}
close GI_MAP;

while (<LIST>) {
  chomp;
  /^>gi\|(\d+)/ or next;
  my $taxid = $found_taxids{$1};
  if (defined $taxid) {
    print "$_\t$taxid\n";
  }
}
