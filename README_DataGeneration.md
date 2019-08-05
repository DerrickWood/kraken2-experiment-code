# Strain exclusion data generation code

This code was run in January 2018; some of the underlying data from NCBI has
changed since then, but similar results should still be obtainable.

## Code to download/extract genome, protein, and taxonomy information

    mkdir Bacteria Viruses Taxonomy
    
    wget -O bacteria.all.fna.tgz \
      ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_refseq/Bacteria/all.fna.tar.gz
    wget -O viruses.all.fna.tgz \
      ftp://ftp.ncbi.nlm.nih.gov/genomes/Viruses/all.fna.tar.gz
    wget -O bacteria.all.faa.tgz \
      ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_refseq/Bacteria/all.faa.tar.gz
    wget -O viruses.all.faa.tgz \
      ftp://ftp.ncbi.nlm.nih.gov/genomes/Viruses/all.faa.tar.gz
    wget -O Taxonomy/gi_taxid_dmp.gz \
      ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/gi_taxid_dmp.gz
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
    
    tar -C Bacteria -xf bacteria.all.fna.tgz
    tar -C Bacteria -xf bacteria.all.faa.tgz
    tar -C Viruses -xf viruses.all.fna.tgz
    tar -C Viruses -xf viruses.all.faa.tgz
    tar -C Taxonomy -xf taxdump.tar.gz
    gunzip Taxonomy/gi_taxid_dmp.gz

## Code to select the strains for exclusion

    # Look at all genome files, only select those with "complete genome",
    # exclude plasmids and 2nd/3rd chromosomes; this gives a list containing one
    # entry per genome.
    find Bacteria/ -name '*.fna' | xargs cat | grep '^>' | grep "complete genome" \
      | grep -v plasmid | grep -v 'chromosome \(2\|3\|II\)' > bacteria_headers.list

    # Add taxid info to that list
    add_taxids.pl bacteria_headers.list Taxonomy/gi_taxid_nucl.dmp \
      > bacteria_taxids.list

    # Given taxid list, report taxids that are good candidates (2 sister species &
    # 2 sister subspecies taxa present).  Sort list by genus, then species, then strain
    # taxids.  Select one entry per genus at random.  Command prints out a blank line at
    # top, so discard, then shuffle entries.  Select first 40 entries.
    report_candidates.pl bacteria_taxids.list | sort -k3,3n -k2,2n -k1,1n \
      | perl -anle 'BEGIN { srand(42) } if ($F[2] == $l) { push @x, $_ } else { print $x[rand @x]; @x = ($_) } $l = $F[2]; END { print $x[rand @x] }' \
      | tail -n +2 | perl -MList::Util=shuffle -le 'srand 42; print shuffle(<>)' \
      | head -40 > selected_bacteria.list
    
    # Same as with bacteria, but only select 10 entries because there are fewer
    # genus candidates.
    find Viruses/ -name '*.fna' | xargs cat | grep '^>' | grep "complete genome" \
      | grep -v segment > viruses_headers.list
    add_taxids.pl viruses_headers.list Taxonomy/gi_taxid_nucl.dmp \
      > viruses_taxids.list
    report_candidates.pl viruses_taxids.list | sort -k3,3n -k2,2n -k1,1n \
      | perl -anle 'BEGIN { srand(42) } if ($F[2] == $l) { push @x, $_ } else { print $x[rand @x]; @x = ($_) } $l = $F[2]; END { print $x[rand @x] }' \
      | tail -n +2 | perl -MList::Util=shuffle -le 'srand 42; print shuffle(<>)' \
      | head -10 > selected_viruses.list

    cat selected_{bacteria,viruses}.list > selected_all.list

## Gather all nucleotide data, and add taxonomy information

    find Bacteria/ Viruses/ -name '*.fna' | xargs cat > original_data.fna
    rewrite_fasta.pl original.fna > rewritten_data.fna

## Use nucleotide taxonomy information for protein data
    grep '^>' rewritten_data.fna \
      | perl -nle '/^>gi\|\d+\|ref\|(\w+).\d+\|kraken:taxid\|(\d+)\|/ and print "$1\t$2"' > acc2taxid.map
    find Bacteria/ Viruses/ -name '*.faa' \
      | xargs assign_protein_taxids.pl acc2taxid.map > rewritten_data.faa

# Perform strain exclusion using the selection lists
    cut -f1 selected_all.list | filter_fasta.pl rewritten_data.fna \
      > strain_excluded.fna
    cut -f1 selected_all.list | filter_fasta.pl rewritten_data.faa \
      > strain_excluded.faa

# Create references for selected projects
    mkdir -p Selected/{bacteria,viruses}
    cut -f1 selected_all.list | ./select_fasta.pl rewritten_data.fna
    cd Selected
    cut -f1 ../selected_viruses.list | xargs -n1 -I{} mv {}.fa viruses
    cut -f1 ../selected_bacteria.list | xargs -n1 -I{} mv {}.fa bacteria

# Simulate read data from selected genomes
    for group in bacteria viruses; do
      for file in $group/*.fa; do
        mason_simulator -ir $file --seed 42 -n 500000 --num-threads 4 \
          -o $group/$(basename $file .fa)_1.fq \
          -or $group/$(basename $file .fa)_2.fq \
          --read-name-prefix taxid_$(basename $file .fa).
      done

      # Grab the first 1000 reads for accuracy study
      head -qn 4000 $group/*_1.fq > ${group}_1.fq
      head -qn 4000 $group/*_2.fq > ${group}_2.fq
    done
