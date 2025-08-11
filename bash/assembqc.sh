#!/bin/bash
# Assembly QC

# ---- Run CheckM ----

# --- write job start time
echo "Job started at $(date)"

# --- activate conda env
source ~/.bashrc
eval "$(conda shell.bash hook)"
conda activate checkm

# --- set paths
export CHECKM_DATA_PATH=/storage/home/smk459/work/programs/checkM
ASSEMB=/your/path/to/workingdir/3.0-unicycler_entero/assemblies
OUT=/your/path/to/workingdir/3.1-uniqc

mkdir -p ${OUT}

cd ${ASSEMB}

echo "CheckM started at $(date)"

  checkm lineage_wf -f "${OUT}/checkm.tsv" -x fasta ${ASSEMB} ${OUT}/checkm --tab_table

echo "CheckM ended at $(date)"

conda deactivate

# ---- Run QUAST ----

echo "QUAST started at $(date)"


python /your/path/to/quast/quast.py \
-o ${OUT}
echo "Job ended at $(date)"
