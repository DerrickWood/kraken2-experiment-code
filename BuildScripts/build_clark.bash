#!/bin/bash

set -e

working_root="/data"

output_dir="$working_root/Databases/CLARK"
reference="$working_root/RefData/strain_excluded.fna"
db_name="strex_genus"
splitter="$working_root/Utilities/split_fasta.pl"

build_prog1="/data/Programs/CLARKSCV1.2.4/set_targets.sh"
build_prog2="/data/Programs/CLARKSCV1.2.4/classify_metagenome.sh"

mkdir -p $output_dir/$db_name/{Custom,taxonomy}

echo "Splitting up data for CLARK"
(cd $output_dir/$db_name/Custom; $splitter $reference)

cp $working_root/RefData/{nodes,names,merged}.dmp $output_dir/$db_name/taxonomy/

# Skips taxonomy download
touch $output_dir/$db_name/.taxondata

echo "Setting up taxonomy for CLARK"
# Use embedded taxids to assign file taxids
find $output_dir/$db_name/Custom -type f | xargs \
  perl -nle '/^>.*\|kraken:taxid\|(\d+)/ and print "$ARGV\t1\t$1"' \
  > $output_dir/$db_name/.custom.fileToAccssnTaxID

cd $(dirname $build_prog1)

echo "Running set targets for CLARK database (genus)"
./$(basename $build_prog1) $output_dir/$db_name custom --genus

echo "Running classify metagenome to build CLARK database (genus)"
# Classify metagenome builds DB on first run, so we run w/ single read to build
./$(basename $build_prog2) -O $working_root/ReadData/single.fa \
  -R $output_dir/$db_name/meaningless_output
