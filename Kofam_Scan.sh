#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=10
#SBATCH --mem=250G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk


module load anaconda3
source activate kofamscan

for i in *.faa;do exec_annotation --cpu 10 -f mapper -k /uoa/scratch/shared/Soil_Microbiology_Group/Reference_databases/kofam/ko_list -p /uoa/scratch/shared/Soil_Mic$


# Modify output:
grep "K" test_cluster_repseq.faa.kofam > test_cluster_repseq.faa.kofam_grep_K
