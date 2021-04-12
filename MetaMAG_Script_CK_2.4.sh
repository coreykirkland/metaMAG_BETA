#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk


### MetaMAG Script (If Bam Files Created) Updated: 31/3/21 ###

## Required Files/Directories:
# Working directory where sample directories are located (LINK)
# Sample directory (MG) 
# edgeR.R script in working directory (i.e. LINK)
# Group_Table.tsv (for edgeR) in working directory (i.e. LINK)

##Note: MG name must be one word with no spacing or special characters! (i.e. AcS10 or SubAcS10)

module load anaconda3

###########################################

## PART 4 ##

## (2) GF TPM Level: ##
# Create a Group_Table.tsv containing sample names in one column followed by catagory (e.g. surface/subsurface) in a second column

edgeROutput="$LINK"/MetaMAG/

#Rscript: saved as edgeR.R in working directory
Rscript "$LINK"/edgeR.R "$LINK"/MetaMAG/TotalTPM.tsv "$LINK"/Group_Table.tsv "$edgeROutput"

# Output: TopTags.tsv ## The top 100 differentially expressed GFs.

## END OF PART 4 ##

###########################################