#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=20
#SBATCH --mem=1000G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk
#SBATCH --array=1-n


### MetaMAG Script (If Bam Files Created) Updated: 8/4/21 ###

## Required Files/Directories:
# Working directory where sample directories are located (LINK)
# Sample directory (MG) 
# Assembly file in MG (named final_assembly.fasta)
# BAM file in MG directory (named "$MG".bam)
# SNV.R script in working directory (i.e. LINK)

##Note: MG name must be one word with no spacing or special characters! (i.e. AcS10 or SubAcS10)

# Use for an Array and create job_list.txt file:
MG=`head -$SLURM_ARRAY_TASK_ID job_list.txt | tail -1`

# Variables:
LINK=/uoa/home/s02ck0/sharedscratch
MetaMAG="$LINK"/"$MG"/"$MG"_MetaMAG

module load anaconda3

###########################################

## PART 5 ##

## (3) SNV Level: ##

# FASTA file = contigs
# BAM file = bowtie2 output (.bam)
# Gene file = Prokka output (.ffn)

# Make new directories:
mkdir "$MetaMAG"/"$MG"_inStrain

# Modify .fna header:
cut "$MetaMAG"/"$MG"_prodigal/"$MG".fna -f 3,4,5,6 -d "_" --complement | cut -f 1,9 -d " " | cut -f 1 -d ";" | sed "s/ ID=/_GeneID=/" | sed "s/>/>"$MG"_/" > "$MetaMAG"/"$MG"_prodigal/"$MG"_renamed.fna

# Variables:
inStrainDIR="$MetaMAG"/"$MG"_inStrain

# inStrain            
source activate inStrain

inStrain profile "$LINK"/"$MG"/"$MG".bam "$LINK"/"$MG"/final_assembly.fasta -o "$inStrainDIR"/"$MG"_output.IS -p 20 -g "$MetaMAG"/"$MG"_prodigal/"$MG"_renamed.fna --skip_genome_wide --skip_plot_generation --debug --skip_mm_profiling

# SNV per Gene and Gene Family:

SNVOutput="$MetaMAG"/"$MG"_

# SNV.R Script:
module load r-4.0.2
Rscript "$LINK"/SNV.R "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv "$LINK"/MetaMAG/mmseqs2/cluster2.tsv "$MetaMAG"/MergedMAG.tsv "$SNVOutput"

# Output Files: "$MG"_SNVs.tsv "$MG"_NucDiv.tsv "$MG"_pNpS.tsv

## END OF PART 5 ##

###########################################