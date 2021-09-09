#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk

#SBATCH --array=1-24


### MetaMAG Script (If Bam Files Created) Updated: 09/09/21 ###

## Required Files/Directories:
# Working directory where sample directories are located (LINK)
# Sample directory (MG) 
# GF_MAGs.R in working directory (i.e. LINK)
# PATH to bin directory (see below). Create a symbolic link in "$MetaMAG" directory - i.e. ln -s <PATH to Binning Directory> <Binning_Directory>

## Note: MG name must be one word with no spacing or special characters! (i.e. AcS10 or SubAcS10)

# For multiple MGs - Use an array and create job_list.txt file:
MG=`head -$SLURM_ARRAY_TASK_ID job_list.txt | tail -1`

# For individual MG:
#MG=

# Variables:
LINK=/uoa/scratch/shared/Soil_Microbiology_Group/Soil_metagenomics_CK_PS/Analysis_All_MGs
MetaMAG="$LINK"/"$MG"/"$MG"_MetaMAG

# PATH to bin directory:
BINNING=/uoa/scratch/shared/Soil_Microbiology_Group/Soil_metagenomics_CK_PS/Combined_new_MAGs/"$MG"

module load anaconda3

###########################################

## PART 3 ##

## (1) TPM GF/MAG Level: ##

# Modify bin files with bin name - for a given MG.
mkdir "$MetaMAG"/"$MG"_Renamed_Bin

# cd to bin directory:
cd "$BINNING"

for bin in *.fa; do
	sed "s/>/>"$MG"_"$bin"_/" $bin > "$MetaMAG"/"$MG"_Renamed_Bin/"$MG"_"$bin"_renamed.fa
done

cd "$LINK"

# Concatenate all renamed bin files into one file
cat "$MetaMAG"/"$MG"_Renamed_Bin/*_renamed.fa > "$MetaMAG"/"$MG"_Renamed_Bin/"$MG"_combined_bin.fa

# Create table with fasta headers from renamed bins
grep '>' "$MetaMAG"/"$MG"_Renamed_Bin/"$MG"_combined_bin.fa | sed "s/>//" > "$MetaMAG"/"$MG"_MAG_Table.tsv

# Modify GFF files and create table
grep -v "#" "$MetaMAG"/"$MG"_prodigal/"$MG".gff | cut -f 1,9 | sed "s/;/\t/" | sed "s/_/\t/2" | cut -f 1,3 | sed "s/ID=//" > "$MetaMAG"/"$MG"_MAG_Table_Updated.tsv

# Filter PercentTPM table by MG:
awk -v awkvar="$MG" '$3 == awkvar' "$LINK"/MetaMAG/PercentTPM.tsv > "$LINK"/MetaMAG/"$MG"_PercentTPM.tsv

# RScript: Merge MAG_Table.tsv, MAG_Table_Updated.tsv, and PercentTPM.tsv
MAGOutput="$MetaMAG"/"$MG"_

module load r-4.0.2

Rscript "$LINK"/MAGPercent.R "$MetaMAG"/"$MG"_MAG_Table.tsv "$MetaMAG"/"$MG"_MAG_Table_Updated.tsv "$LINK"/MetaMAG/"$MG"_PercentTPM.tsv "$MAGOutput"

# Outputs: MAGPercentGF.tsv MAGPercentKO.tsv MergedMAG.tsv MAGPercent.tsv

## END OF PART 3 ##

###########################################