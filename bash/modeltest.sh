#!/bin/bash
#ModelTest for Phylogeny


#--- write job start time
echo "Job started at $(date)"

#--- set paths
ROARY=/your/path/to/workingdir/4.1-roary
OUT=/your/path/to/workingdir/5.0-modeltest

mkdir -p ${OUT}

#--- run program
/your/path/to/modeltest/bin/modeltest-ng -i ${ROARY}/core_gene_alignment.aln \
-o ${OUT} \
-t ml \
-d nt \
-T raxml \
-p 8

#--- write job end time
echo "Job ended at $(date)"
