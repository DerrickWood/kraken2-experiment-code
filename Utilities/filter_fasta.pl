#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw/:seek/;

my $taxonomy = "Taxonomy/";
my $fasta_file = shift;

chomp(my @excluded_taxids_list = <>);
my %excluded_taxids = map {($_ => 1)} @excluded_taxids_list;

my %parent_map;
my %rank_map;
my %name_map;

open NODES, "<", "$taxonomy/nodes.dmp"
  or die "can't open $taxonomy/nodes.dmp: $!\n";
while (<NODES>) {
  chomp;
  my @fields = split /\t\|\t/;
  my ($node, $parent, $rank) = @fields[0..2];
  $parent_map{$node} = $parent;
  $rank_map{$node} = $rank;
}
close NODES;

open NAMES, "<", "$taxonomy/names.dmp"
  or die "can't open $taxonomy/names.dmp: $!\n";
while (<NAMES>) {
  chomp;
  my @fields = split /\t\|\t?/;
  my ($node, $name, $type) = @fields[0, 1, 3];
  $name_map{$node} = $name if $type eq "scientific name";
}
close NAMES;

open FASTA, "<", $fasta_file
  or die "can't open fasta file $fasta_file: $!\n";
my $printing_sequence = 0;
while (<FASTA>) {
  if (/^>/) { 
    $printing_sequence = 1;
    if (/kraken:taxid\|(\d+)/) {
      my $taxid = $1;
      STEP: while ($taxid != 1) {
        if (exists $excluded_taxids{$taxid}) {
	  $printing_sequence = 0;
	  last STEP;
	}
	$taxid = $parent_map{$taxid};
      }
    }
  }
  print if $printing_sequence;
}
