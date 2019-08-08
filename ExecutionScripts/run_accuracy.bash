#!/bin/bash

set -e

working_root="/data"
results_dir="$working_root/Results"
read_file1="$working_root/ReadData/accuracy_1.fq"
read_file2="$working_root/ReadData/accuracy_2.fq"

## Run Kraken 1
kraken1="$working_root/Programs/k1-install/kraken"

echo "Running Kraken 1"
$kraken1 --preload --db $working_root/Databases/Kraken1/strex --threads 16 \
  --paired $read_file1 $read_file2 > $results_dir/strex_kraken1.out
cut -f 2-3 $results_dir/strex_kraken1.out > $results_dir/strex_kraken1.res

## Run KrakenUniq
krakenUniq="$working_root/Programs/KrakenUniq/krakenuniq"

echo "Running KrakenUniq"
$krakenUniq --preload --db $working_root/Databases/KrakenUniq/strex --threads 16 \
  --paired $read_file1 $read_file2 > $results_dir/strex_krakenUniq.out
cut -f 2-3 $results_dir/strex_krakenUniq.out > $results_dir/strex_krakenUniq.res


## Run Kraken 2
kraken2="$working_root/Programs/k2-install/kraken2"

echo "Running Kraken 2"
$kraken2 --db $working_root/Databases/Kraken2/strex --threads 16 \
  --paired $read_file1 $read_file2 > $results_dir/strex_kraken2.out
cut -f 2-3 $results_dir/strex_kraken2.out > $results_dir/strex_kraken2.res

## Run Kraken 2X
echo "Running Kraken 2X"
$kraken2 --db $working_root/Databases/Kraken2X/strex --threads 16 \
  --paired $read_file1 $read_file2 > $results_dir/strex_kraken2x.out
cut -f 2-3 $results_dir/strex_kraken2x.out > $results_dir/strex_kraken2x.res

## Run Kaiju
kaiju="$working_root/Programs/kaiju-v1.5.0-linux-x86_64-static/bin/kaiju"

echo "Running Kaiju"
$kaiju -t $working_root/RefData/nodes.dmp -f $working_root/Databases/Kaiju/strex.fmi \
  -i $read_file1 -j $read_file2 -z 16 -o $results_dir/strex_kaiju.out
cut -f 2-3 $results_dir/strex_kaiju.out > $results_dir/strex_kaiju.res

## Run Centrifuge
centrifuge="$working_root/Programs/centrifuge"

echo "Running Centrifuge"
$centrifuge -x $working_root/Databases/Centrifuge/strex -1 $read_file1 -2 $read_file2 \
  -S $results_dir/strex_centrifuge.out -k 1 -p 16
cut -f 1,3 $results_dir/strex_centrifuge.out | tail -n +2 > $results_dir/strex_centrifuge.res

## Run CLARK (genus)
clark__dir="$working_root/Programs/CLARKSCV1.2.4"

echo "Running CLARK (genus)"
(cd $clark_dir; \
  ./set_targets.sh $working_root/Databases/CLARK/strex_genus custom --genus; \
  ./classify_metagenome.sh -P $read_file1 $read_file2 -n 16 -R $results_dir/strex_clark_genus \
)
tail -n +2 $results_dir/strex_clark_genus.csv | grep -v ',NA$' \
  | cut -d, -f1,3 | sed -e 's/,/  /' > $results_dir/strex_clark_genus.res
