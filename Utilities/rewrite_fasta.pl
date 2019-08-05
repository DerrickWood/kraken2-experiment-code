#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw/:seek/;

my $taxonomy = "Taxonomy/";
my $fasta_file = shift;

open FASTA, "<", $fasta_file
  or die "can't open fasta file $fasta_file: $!\n";
my %requested_ginums;
while (<FASTA>) {
  /^>gi\|(\d+)/ and $requested_ginums{$1}++;
}
seek FASTA, 0, SEEK_SET;

my %merged_map;
open MERGED, "<", "$taxonomy/merged.dmp"
  or die "can't open $taxonomy/merged.dmp: $!\n";
while (<MERGED>) {
  chomp;
  my @fields = split /\t\|\t?/;
  my ($node, $new_node) = @fields[0, 1];
  $merged_map{$node} = $new_node;
}
close MERGED;

my $gi_taxid_map_file = "$taxonomy/gi_taxid_nucl.dmp";
open GI_MAP, "<", $gi_taxid_map_file
  or die "can't open map $gi_taxid_map_file: $!\n";
my %found_taxids;
while (<GI_MAP>) {
  chomp;
  my ($gi, $taxid) = split;
  next unless exists $requested_ginums{$gi};
  if (exists $merged_map{$taxid}) {
    $taxid = $merged_map{$taxid};
  }
  $found_taxids{$gi} = $taxid;
}
close GI_MAP;

my $printing_sequence = 0;
while (<FASTA>) {
  if (/^>/) { 
    $printing_sequence = 0;
    if (/gi\|(\d+)/ && exists $found_taxids{$1}) {
      my $taxid = $found_taxids{$1};
      s/\|\s/|kraken:taxid|$taxid| /;
      $printing_sequence = 1;
    }
  }
  print if $printing_sequence;
}
