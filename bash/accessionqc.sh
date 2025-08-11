#!/bin/bash

# Raw Read Accession and Quality Control

# --- write job start time
echo "Job started at $(date)"

# --- activate conda env
source ~/.bashrc
eval "$(conda shell.bash hook)"
conda activate bioinfo

# --- download raw reads from sra

WD=/your/path/to/workingdir

cd ${WD}/0.0-raw # create this directory ahead of time and have the accession list saved here

for i in `cat acclist.txt`; do printf ${i}"\t"; fasterq-dump ${i} --split-files; done

echo "File compression started at $(date)"

# compress files 
gzip *RR*


# ---- run FastQC and MultiQC on raw reads ----

echo "Read QC started at $(date)"

mkdir -p ${WD}/0.1-rawqc

# --- run fastqc
fastqc *.gz -o "${WD}/0.1-rawqc" -t 10

# --- multiqc

export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

multiqc ${WD}/0.1-rawqc*_fastqc.zip --interactive

# --- run seqkit
seqkit stats *.gz -T > ${WD}/0.1-rawqc/rawstats.txt

# --- write job end time
echo "Job ended at $(date)"
