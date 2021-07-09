#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=10
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk
#SBATCH --array=1-24


### MetaMAG Script (If Bam Files Created) Updated: 17/6/21 ###

## Required Files/Directories:
# Working directory where sample directories are located (LINK)
# Sample directory (MG)
# Assembly file in MG (named final_assembly.fasta)
# BAM file in MG directory (named "$MG".bam)
# SNV.R script in working directory (i.e. LINK)

## Note: MG name must be one word with no spacing or special characters! (i.e. AcS10 or SubAcS10)

# For multiple MGs - Use an array and create job_list.txt file:
MG=`head -$SLURM_ARRAY_TASK_ID job_list.txt | tail -1`

# For individual MG:
# MG=AcS1

# Variables:
LINK=/uoa/scratch/shared/Soil_Microbiology_Group/Soil_metagenomics_CK_PS/Analysis_All_MGs
MetaMAG="$LINK"/"$MG"/"$MG"_MetaMAG

module load anaconda3

###########################################

## PART 5 ##

## (3) SNV Level: ##

# Make new directories:
mkdir "$MetaMAG"/"$MG"_inStrain

# Variables:
inStrainDIR="$MetaMAG"/"$MG"_inStrain

# inStrain            
source activate inStrain_v1.5.3

inStrain profile "$LINK"/"$MG"/"$MG".bam "$LINK"/"$MG"/"$MG"_final_assembly.fasta -o "$inStrainDIR"/"$MG"_output.IS -p 10 -g "$MetaMAG"/"$MG"_prodigal/"$MG".fna --skip_genome_wide --skip_plot_generation --debug --skip_mm_profiling

###########################################

# SNV per Gene and Gene Family:

## Note: GF/Cluster_Rep name modified to remove "GeneID=n". Therefore, GF name different in this section to all other sections. Still contains contig and gene number. ##

# Modify inStrain Gene Output:
gzip -d "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv.gz

sed -i "1 s/$/\tMG/" "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv
sed -i "2,$ s/$/\t$MG/" "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv

# Modify cluster2 (containing only GFs with multiple genes):

sed "s/_/\t/4" "$LINK"/MetaMAG/mmseqs2/cluster2.tsv > "$LINK"/MetaMAG/mmseqs2/cluster3.tsv
sed -i "s/_/\t/8" "$LINK"/MetaMAG/mmseqs2/cluster3.tsv
cut -f 1,3 "$LINK"/MetaMAG/mmseqs2/cluster3.tsv > "$LINK"/MetaMAG/mmseqs2/cluster4.tsv

SNVOutput="$MetaMAG"/"$MG"_

# SNV.R Script:
module load r-4.0.2
Rscript "$LINK"/SNV.R "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv "$LINK"/MetaMAG/mmseqs2/cluster4.tsv "$MetaMAG"/"$MG"_MergedMAG.tsv "$SNVOutput"

# Output Files: "$MG"_SNVs.tsv "$MG"_NucDiv.tsv "$MG"_pNpS.tsv "$MG"_MergedDfNaOmit.tsv "$MG"_GeneSNV_MAG.tsv

## END OF PART 5 ##

###########################################