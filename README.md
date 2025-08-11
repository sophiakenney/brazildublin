# Contextualization of Brazilian *Salmonella* Dublin among global strains

## Publication 

## Repository Structure and Analysis Pipeline 

### Directory contents

*   `bash` contains all code used to perform the analysis and generate output tables used in RStudio
  
      * subdir `condaenv_yaml` contains yaml files for all conda environments needed for the analysis

*    `R` contains all code used to perform downstream analysis and data visualizations used in the manuscript

      * `assembqc` : assembly qc tables 
      * `meta` : metadata for final dataset
      * `phylo` : SNP distance matrix, and tree file
      * `readqc` : read qc tables
      * `script` : all R scripts
      * `query` : initial query table used for dataset

### Analysis Pipeline 

#### **HPC Component**

Bash scripts should be run in roughly this order: 

1. accessionqc.sh - download reads and generate qc reports
2. trimqc.sh - qc reads and generate qc reports
3. classify.sh - taxonomic classification to check for contamination
4. extactreads.sh - filter for *Enterobacteriaceae* reads
5. assembly.sh - genome assembly
6. assembqc.sh - assembly qc

Once assemblies have been constructed all of the following can be run somewhat concurrently:

* sistr.sh - *in silico* serotyping
* seqsero.sh - *in silico* serotyping
* mlst.sh - cgMLST assignment
* prokka.sh - genome annotation

Followed by Roary:

* roary.sh - pangenome annotation and core genome alignment

The following can be run after Roary completes:
1. modeltest.sh - determine best nucleotide substitution model for phylogenetic tree building
2. iqtree.sh - build phylogenetic tree

#### **RStudio Component**

Recommended order:

1. queryfilt.R - filter query for strains to include
2. readqc.R - evaluate read qc for downstream inclusion
3. assembqc.R - evaluate assembly qc for downstream inclusion
4. phylo.R - plot phylogenetic tree


