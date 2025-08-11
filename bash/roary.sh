#!/bin/bash
# Pangenome analysis: Roary

# --- write job start time
echo "Job started at $(date)"

#activate conda env
source ~/.bashrc
eval "$(conda shell.bash hook)"
conda activate roary_env

#set directory paths
GFF=/your/path/to/workingdir/4.0-prokka/gff
OUT=/your/path/to/workingdir/4.1-roary

mkdir -p ${OUT}

cd ${GFF}

roary -e --mafft -p 10 *.gff -f ${OUT} -v

# --- write job end time
echo "Job ended at $(date)"
