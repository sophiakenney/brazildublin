#!/bin/bash
# Raw Read Accession and Quality Control

# --- write job start time
echo "Job started at $(date)"

# --- activate conda env
source ~/.bashrc
eval "$(conda shell.bash hook)"
conda activate bioinfo

# --- trim raw reads ---

WD=/your/path/to/workingdir
ADAPTERS=/your/path/to/trimmomatic-0.39-2/adapters/

mkdir -p ${WD}/1.0-trimmed/
mkdir -p ${WD}/1.1-trimqc

cd ${WD}/0.0-raw

for f in *_1.fastq.gz
do
outfile=${f%_1.fastq.gz}.fastq.gz
echo "${f}"

/storage/home/smk459/work/conda_envs/bioinfo/bin/trimmomatic PE "${f}" "${f%_1.fastq.gz}_2.fastq.gz" \
-baseout "${WD}/1.0-trimmed/${outfile}" -threads 10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 ILLUMINACLIP:${ADAPTERS}TruSeq3-PE-2.fa:2:30:10

done

# repeat with nextera adapters

echo "Starting Nextera adapters at $(date)"

cd ${WD}/1.0-trimmed

for f in *_1P.fastq.gz
do
outfile=${f%_1P.fastq.gz}.fq.gz
echo "${f}"

/storage/home/smk459/work/conda_envs/bioinfo/bin/trimmomatic PE "${f}" "${f%_1P.fastq.gz}_2P.fastq.gz" \
-baseout "${WD}/1.0-trimmed/${outfile}" -threads 10 ILLUMINACLIP:${ADAPTERS}NexteraPE-PE.fa:2:30:10:2:True

done

# ---- trimmed read QC ----

echo "Starting readqc at $(date)"

# run fastqc
fastqc *P.fq.gz -o "${WD}/1.1-trimqc" -t 10

# multiqc

export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

multiqc ${WD}/1.1-trimqc/*_fastqc.zip \
    -o  ${WD}/1.1-trimqc \
    --interactive

# run seqkit
seqkit stats *.gz -T > ${WD}/1.1-trimqc/trimstats.txt

# --- write job end time
echo "Job ended at $(date)"
