# Scripts for the evaluation of accuracy and resource usage

## Accuracy evaluation

run\_accuracy.bash is the script used to run the classifiers during
our accuracy evaluation on strain exclusion data.  The `*.res` files
are intended to be two-column tab-separated value files, with each
line containing a fragment ID and taxonomic ID.  A taxonomic ID of
0 is considered to be an unclassified fragment.

Results are obtained by comparing the `truth_bacteria.tsv` and
`truth_virus.tsv` files with the `*.res` files, using the
`evaluate_calls` command, e.g.:

    evaluate_calls nodes.dmp genus truth_bacteria.tsv strex_kraken2.res

## Timing evaluation

For the timing and memory usage evaluation, we similarly evaluated
the various classifiers on a larger set of reads, but used a RAM
filesystem to eliminate the impact of disk and network I/O on runtime.

As the superuser ("root"), we ran the following commands to
initialize the environment:

    # Create directory for and mount RAMFS
    mkdir /ramdisk
    mount –t ramfs none /ramdisk

    # Copy data files to RAMFS
    cp /data/ReadData/timing_1.fq /ramdisk
    cp /data/ReadData/timing_2.fq /ramdisk

    # Allow regular user to read/write from RAMFS
    chown –R ubuntu:ubuntu /ramdisk

We then run the `run_timing.bash` script as the regular user ("ubuntu").
Results are manually parsed from the `/usr/bin/time` command.
