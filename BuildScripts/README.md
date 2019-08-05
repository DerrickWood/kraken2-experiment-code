# Scripts to build databases for various classifiers

These are the scripts we used to build the databases in our
strain exclusion experiments for the Kraken 2 manuscript.
In some cases, these differ from the normal method of execution
to allow the various classification tools to use a common
reference and taxonomy.

## Notes for specific classifiers

### Centrifuge

We perform explicit low-complexity masking for Centrifuge because
it uses such masking in its default installation.  Our need to force
Centrifuge to use the same references and taxonomy as the other
classifiers required circumventing that installation here.

### CLARK

Because CLARK does not use a separate build program, and instead
builds its database when a classification is attempted with a
non-existent database, we force a build using a classification
with a file containing a single read ("single.fa").  By building
the database in this manner, the build time and memory usage
will not be counted against CLARK during our evaluations of
classification runtime and memory efficiency.  We also use a
script we created ("split\_fasta.pl") that simply takes a
multi-FASTA file as input and outputs a collection of single-FASTA
files into the current directory; we do this because CLARK
requires single-FASTA reference data.

### KrakenUniq

KrakenUniq is largely compatible with Kraken 1, and can be run
with Kraken 1 databases.  To build a KrakenUniq database, we simply
used the built Kraken 1 DB and ran KrakenUniq’s "krakenuniq" command
on it with a single-read FASTA file as input to cause KrakenUniq to
build the extra files it requires ("database.kdb.counts" and "taxDB").
