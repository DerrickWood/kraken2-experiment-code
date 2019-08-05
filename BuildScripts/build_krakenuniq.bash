#!/bin/bash

set -e

working_root="/data"

template_dir="$working_root/Databases/Kraken1"
output_dir="$working_root/Databases/KrakenUniq"
db_name="strex"

build_prog="$working_root/Programs/krakenuniq/krakenuniq"

mkdir –p $output_dir
cp –a $template_dir/$db_name $output_dir/.

$build_prog --db $output_dir/$db_name --report-file /tmp/null.out single.fa > /dev/null
