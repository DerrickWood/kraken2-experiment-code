#!/bin/bash

set -e

working_root="/data"

output_dir="$working_root/Databases/Kraken1"
reference="$working_root/RefData/strain_excluded.fna"
db_name="strex"

build_prog="$working_root/Programs/k1-install/kraken-build"

mkdir -p $output_dir/$db_name/taxonomy

cp $working_root/RefData/{nodes,names}.dmp $output_dir/$db_name/taxonomy/

echo "Adding reference to Kraken 1 library"
$build_prog --db $output_dir/$db_name --add-to-library $reference

echo "Running build program for Kraken 1"
$build_prog --db $output_dir/$db_name --threads 32 --build
