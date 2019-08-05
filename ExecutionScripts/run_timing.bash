#!/bin/bash

db_root=/ramdisk/db
output_file=/ramdisk/file.out
data_file1=/ramdisk/timing_1.fq
data_file2=/ramdisk/timing_2.fq

cd /ramdisk

# Run Kraken 2
echo "Run Kraken 2"
mkdir $db_root
cp /data/Databases/Kraken2/strex/*.k2d $db_root
taskset -c 0-15 /usr/bin/time -v /data/Programs/k2-install/kraken2 \
  --db $db_root --memory-mapping --threads 16 --paired \
  --output $output_file $data_file1 $data_file2
rm -rf $db_root $output_file

# Run Kraken 2X
echo "Run Kraken 2X"
mkdir $db_root
cp /data/Databases/Kraken2X/strex/*.k2d $db_root
taskset -c 0-15 /usr/bin/time -v /data/Programs/k2-install/kraken2 \
  --db $db_root --memory-mapping --threads 16 --paired \
  --output $output_file $data_file1 $data_file2
rm -rf $db_root $output_file

# Run Kraken 1
echo "Run Kraken 1"
mkdir -p $db_root/taxonomy
cp /data/Databases/Kraken1/strex/database.* $db_root
cp /data/Databases/Kraken1/strex/taxonomy/{names,nodes}.dmp $db_root/taxonomy/
taskset -c 0-15 /usr/bin/time -v /data/Programs/k1-install/kraken \
  --db $db_root --threads 16 --paired --output $output_file \
  $data_file1 $data_file2

# Run KrakenUniq
echo "Run KrakenUniq"
cp /data/Databases/KrakenUniq/strex/{database.kdb.counts,taxDB} $db_root
taskset -c 0-15 /usr/bin/time -v /data/Programs/KrakenUniq/krakenuniq \
  --db $db_root --threads 16 --paired --report-file off \
   $data_file1 $data_file2 > $output_file
rm -rf $db_root $output_file off

# Run Centrifuge
echo "Run Centrifuge"
mkdir $db_root
cp /data/Databases/Centrifuge/strex.* $db_root
taskset -c 0-15 /usr/bin/time -v /data/Programs/centrifuge -x $db_root/strex \
  -1 $data_file1 -2 $data_file2 -S $output_file -k 1 -p 16
rm -rf $db_root $output_file centrifuge_report.tsv

# Run CLARK
echo "Run CLARK"
mkdir -p $db_root/custom_1
cp /data/Databases/CLARK/strex_genus/custom_1/* $db_root/custom_1
cp /data/Databases/CLARK/strex_genus/.custom* $db_root
cp /data/Databases/CLARK/strex_genus/.taxondata $db_root
cp -a /data/Databases/CLARK/strex_genus/taxonomy $db_root/.
( \
  cd /data/Programs/CLARKSCV1.2.4; \
  ./set_targets.sh $db_root custom --genus; \
  taskset -c 0-15 /usr/bin/time -v ./classify_metagenome.sh \
    -P $data_file1 $data_file2 -n 16 -R $output_file \
)
rm -rf $db_root ${output_file}.csv

# Run Kaiju
echo "Run Kaiju"
mkdir $db_root
cp /data/Databases/Kaiju/strex.fmi $db_root/.
cp /data/RefData/nodes.dmp $db_root/.
taskset -c 0-15 /usr/bin/time -v \
  /data/Programs/kaiju-v1.5.0-linux-x86_64-static/bin/kaiju \
  -t $db_root/nodes.dmp -f $db_root/strex.fmi \
  -i $data_file1 -j $data_file2 -z 16 -o $output_file
rm -rf $db_root $output_file
