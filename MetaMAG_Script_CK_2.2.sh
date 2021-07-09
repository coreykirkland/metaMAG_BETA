#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=30
#SBATCH --mem=1000G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk


### MetaMAG Script (If Bam Files Created) Updated: 09/07/21 ###

## Required Files/Directories:
# Working directory where sample directories are located (LINK)
# Sample directory (MG)
# Mmseqs2Stats.R in working directory (i.e. LINK)
# TPM_GF.R script in working directory (i.e. LINK)

##Note: MG name must be one word with no spacing or special characters! (i.e. AcS10 or SubAcS10)

# Variables:
LINK=/uoa/scratch/shared/Soil_Microbiology_Group/Soil_metagenomics_CK_PS/Analysis_All_MGs

module load anaconda3

########################################

## PART 2 ##

# Concatenate all TPM files:
cat "$LINK"/MetaMAG/*.tpm > "$LINK"/MetaMAG/Combined_MetaMAG_tpm.tsv

## Cluster all AA seqs using MMseqs2:

# Concatenate all .faa files.
cat "$LINK"/MetaMAG/*.faa > "$LINK"/MetaMAG/Combined_MetaMAG.fasta

# Modify fasta header - now includes contig and gene ID:
cut "$LINK"/MetaMAG/Combined_MetaMAG.fasta -f 4,5,6,7 -d "_" --complement | cut -f 1,9 -d " " | cut -f 1 -d ";" | sed "s/ ID=/_GeneID=/" > "$LINK"/MetaMAG/Combined_MetaMAG1.fasta

# Make Directories:
mkdir "$LINK"/MetaMAG/mmseqs2
mkdir "$LINK"/MetaMAG/mmseqs2/allMG_AA_DB_tmp

source activate mmseqs2

# Create DB (convert .faa files into MMseqs2 database format).
mmseqs createdb "$LINK"/MetaMAG/Combined_MetaMAG1.fasta "$LINK"/MetaMAG/mmseqs2/allMG_AA_DB

# Cluster using cascaded clustering (clusters sequences in DB file by similarity).
# mmseqs cluster --threads (n) --cov-mode (0 = bidirectional coverage) -c (0.8 = 80%) --min-seq-id (target sequence identity) <DatabaseFile> <AaClusterOutputFile> <TpmOutputFile>
mmseqs cluster --threads 30 --cov-mode 0 -c 0.8 --min-seq-id 0.35 "$LINK"/MetaMAG/mmseqs2/allMG_AA_DB "$LINK"/MetaMAG/mmseqs2/allMG_AA_cluster "$LINK"/MetaMAG/mmseqs2/allMG_AA_DB_tmp

# Create tsv file (mmseqs createtsv DB DB DB_clu DB_clu.tsv).
mmseqs createtsv --threads 30 "$LINK"/MetaMAG/mmseqs2/allMG_AA_DB "$LINK"/MetaMAG/mmseqs2/allMG_AA_DB "$LINK"/MetaMAG/mmseqs2/allMG_AA_cluster "$LINK"/MetaMAG/mmseqs2/allMG_AA_cluster.tsv

# Extract representative fasta from each clustering result.
# mmseqs createsubdb DB_clu DB DB_clu_rep
mmseqs createsubdb "$LINK"/MetaMAG/mmseqs2/allMG_AA_cluster "$LINK"/MetaMAG/mmseqs2/allMG_AA_DB "$LINK"/MetaMAG/mmseqs2/test_cluster_repseq
# mmseqs convert2fasta DB_clu_rep DB_clu_rep.fasta
mmseqs convert2fasta "$LINK"/MetaMAG/mmseqs2/test_cluster_repseq "$LINK"/MetaMAG/mmseqs2/test_cluster_repseq.fasta

module load r-4.0.2
MmseqOutput="$LINK"/MetaMAG/
Rscript "$LINK"/Mmseqs2Stats.R "$LINK"/MetaMAG/mmseqs2/allMG_AA_cluster.tsv "$MmseqOutput"

# Output: MmseqsStats.tsv and MmseqsHistogram.pdf

# Remove singletons from cluster.tsv file:
awk -F "\t" '{print $2,$1}' OFS="\t" "$LINK"/MetaMAG/mmseqs2/allMG_AA_cluster.tsv > "$LINK"/MetaMAG/mmseqs2/cluster.tsv

sort -k 2 "$LINK"/MetaMAG/mmseqs2/cluster.tsv | uniq -f 1 -D > "$LINK"/MetaMAG/mmseqs2/cluster1.tsv 

awk -F "\t" '{print $2,$1}' OFS="\t" "$LINK"/MetaMAG/mmseqs2/cluster1.tsv > "$LINK"/MetaMAG/mmseqs2/cluster2.tsv

# cluster2.tsv contains only GFs with multiple genes.

###########################################

# Merge .tpm and cluster2.tsv files - to get TPM per GF/Cluster. Now includes script to calculate number of genes in each GF/cluster.
# Rscript: saved as TPM_GF.R 
# Now calculates for all GFs.
TPMOutput="$LINK"/MetaMAG/

module load r-4.0.2

Rscript "$LINK"/GF_TPM.R "$LINK"/MetaMAG/Combined_MetaMAG_tpm.tsv "$LINK"/MetaMAG/mmseqs2/allMG_AA_cluster.tsv "$TPMOutput"

# Output: TotalTPM.tsv GeneTPM.tsv ClusterCount.tsv PercentTPM.tsv

## END OF PART 2 ##

###########################################