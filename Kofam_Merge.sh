#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk
#SBATCH --array=1-24

# Use for an Array and create job_list.txt file:
MG=`head -$SLURM_ARRAY_TASK_ID job_list.txt | tail -1`

# Variables:
LINK=/uoa/scratch/shared/Soil_Microbiology_Group/Soil_metagenomics_CK_PS/Analysis_All_MGs
MetaMAG="$LINK"/"$MG"/"$MG"_MetaMAG

sed "s/_"$MG"//" "$MetaMAG"/"$MG"_MAGPercent_AllGFs.tsv > "$MetaMAG"/"$MG"_MAGPercent_AllGFs1.tsv

module load r-4.0.2

Output="$MetaMAG"/"$MG"_

Rscript "$LINK"/Kofam_Merge.R "$MetaMAG"/"$MG"_MAGPercent_AllGFs1.tsv "$LINK"/Kofam_Scan_AllGFs/test_cluster_repseq.faa.kofam "$Output"