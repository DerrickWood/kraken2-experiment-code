#!/bin/bash

set -e

working_root="/data"

output_dir="$working_root/Databases/Kaiju"
reference="$working_root/RefData/strain_excluded.faa"
db_name="strex"

build_prog1="$working_root/Programs/kaiju-v1.5.0-linux-x86_64-static/bin/mkbwt"
build_prog2="$working_root/Programs/kaiju-v1.5.0-linux-x86_64-static/bin/mkfmi"

mkdir -p $output_dir

# Prepare headers for Kaiju
sed -e '/^>/ s/^.*kraken:taxid|\([0-9][0-9]*\).*/>\1/' $reference \
  > $output_dir/kaiju_reference.faa

echo "Running BWT program for Kaiju"
$build_prog1 -e 3 -n 32 -o $output_dir/$db_name $output_dir/kaiju_reference.faa

echo "Running FMI program for Kaiju"
$build_prog2 $output_dir/$db_name
