#!/bin/bash

set -e

working_root="/data"

output_dir="$working_root/Databases/Centrifuge"
reference="$working_root/RefData/strain_excluded.fna"
db_name="strex"

build_prog="$working_root/Programs/centrifuge-build"

mkdir -p $output_dir

echo "Creating seqid -> taxid map for Centrifuge"
grep '^>' $reference | sed -e 's/^>//' | awk '{print $1}' | \
  perl -ple 's/^(gi\|\d+)\S*\|kraken:taxid\|(\d+)\S*/$1\t$2/' \
  > $output_dir/${db_name}_seqid2taxid.map

echo "DUST masking reference for Centrifuge"
dustmasker -infmt fasta -in $reference -level 20 -outfmt fasta | \
  sed '/^>/! s/[^ACGT]/N/g' > $output_dir/masked_reference.fa

echo "Running build program for Centrifuge"
$build_prog -p 32 --conversion-table $output_dir/${db_name}_seqid2taxid.map \
  --taxonomy-tree $working_root/RefData/nodes.dmp \
  --name-table $working_root/RefData/names.dmp \
  $output_dir/masked_reference.fa $output_dir/$db_name
