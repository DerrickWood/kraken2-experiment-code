#!/bin/bash

set -e

working_root="/data"

output_dir="$working_root/Databases/Kraken2X"
reference="$working_root/RefData/strain_excluded.faa"
db_name="strex"

build_prog="$working_root/Programs/k2-install/kraken2-build"

mkdir -p $output_dir/$db_name/taxonomy

cp $working_root/RefData/{nodes,names}.dmp $output_dir/$db_name/taxonomy/

echo "Adding reference to Kraken 2 library"
$build_prog --db $output_dir/$db_name --add-to-library $reference --protein

echo "Running build program for Kraken 2"
$build_prog --db $output_dir/$db_name --threads 32 --build –protein
