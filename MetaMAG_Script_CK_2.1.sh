#!/bin/bash

#SBATCH --partition=spot-vhmem
#SBATCH --time=UNLIMITED
#SBATCH --cpus-per-task=20
#SBATCH --mem=1000G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s02ck0@abdn.ac.uk

#SBATCH --array=1-24


### MetaMAG Script (If Bam Files Created) Updated: 09/07/21 ###

## Required Files/Directories:
# Working directory where sample directories are located (LINK)
# Sample directory (MG) 
# Assembly file in MG (named "$MG"_final_assembly.fasta)
# BAM file in MG directory (named "$MG".bam)
# prodigalgff2gtf.sh script in working directory (i.e. LINK)

##Note: MG name must be one word with no spacing or special characters! (i.e. AcS10 or SubAcS10)

# For multiple MGs - Use for an Array and create job_list.txt file:
MG=`head -$SLURM_ARRAY_TASK_ID job_list.txt | tail -1`

# For individual MGs:
#MG=AcS1

# Variables:
LINK=/uoa/scratch/shared/Soil_Microbiology_Group/Soil_metagenomics_CK_PS/Analysis_All_MGs
MetaMAG="$LINK"/"$MG"/"$MG"_MetaMAG

mkdir $MetaMAG

module load anaconda3

###################################

## PART 1 ##

## Annotate metagenome assembly:

# Make prodigal directory.
mkdir "$MetaMAG"/"$MG"_prodigal/

# prodigal <InputFile> <NucleotideOuput> <AminoAcidOutput> <GffOutput> -p meta 
source activate prodigal

prodigal -i "$LINK"/"$MG"/"$MG"_final_assembly.fasta -d "$MetaMAG"/"$MG"_prodigal/"$MG".fna -a "$MetaMAG"/"$MG"_prodigal/"$MG".faa -o "$MetaMAG"/"$MG"_prodigal/"$MG".gff -p meta -f gff

grep ">" "$MetaMAG"/"$MG"_prodigal/"$MG".faa | wc -l > "$MetaMAG"/"$MG"_prodigal/"$MG"_gene_total.txt

######################################

# Alignment Stats - Picard CollectAlignmentSummaryMetrics. See http://broadinstitute.github.io/picard/picard-metric-definitions.html#AlignmentSummaryMetrics for table column definitions.
mkdir "$MetaMAG"/"$MG"_picard
source activate picard

java -Xms2g -Xmx32g -jar /opt/software/uoa/2019/spack/opt/spack/linux-centos7-x86_64/gcc-9.1.0/picard-2.19.0-uc3lvtta7rlpyv2lpvmq347bdrzhx76r/bin/picard.jar CollectAlignmentSummaryMetrics R="$LINK"/"$MG"/"$MG"_final_assembly.fasta I="$LINK"/"$MG"/"$MG".bam O="$LINK"/"$MG"/"$MG"_bam_stats.txt
   
# Identify duplicate reads
# <BamInput> <BamOutput> \ METRICS_FILE=<File> (File to write duplication metrics to) \ MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=<File> (Max no. file handles to keep open when spilling read ends to disk) REMOVE_DUPLICATES=TRUE (TRUE = do not write duplicates to output file instead of writing them with appropriate flags set)
java -Xms2g -Xmx32g -jar /opt/software/uoa/2019/spack/opt/spack/linux-centos7-x86_64/gcc-9.1.0/picard-2.19.0-uc3lvtta7rlpyv2lpvmq347bdrzhx76r/bin/picard.jar MarkDuplicates INPUT="$LINK"/"$MG"/"$MG".bam OUTPUT="$MetaMAG"/"$MG"_picard/"$MG"_map_markdup.bam \
METRICS_FILE="$MetaMAG"/"$MG"_picard/"$MG"_map_markdup.metrics AS=TRUE VALIDATION_STRINGENCY=LENIENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 REMOVE_DUPLICATES=TRUE \
TMP_DIR=/uoa/home/s02ck0/localscratch

# New syntax? Needs testing.
# java -Xms2g -Xmx32g -jar /opt/software/uoa/2019/spack/opt/spack/linux-centos7-x86_64/gcc-9.1.0/picard-2.19.0-uc3lvtta7rlpyv2lpvmq347bdrzhx76r/bin/picard.jar
#MarkDuplicates -INPUT /uoa/home/s02ck0/sharedscratch/Sample_10_MG2/Sample_10_MG2.map.sorted.bam -OUTPUT /uoa/home/s02ck0/sharedscratch/Sample_10_MG2/Sample_10_MG2.map.markdup.bam -METRICS_FILE /uoa/home/s02ck0/sharedscratch/Sample_10_MG2/Sample_10_MG2.map.markdup.metrics -AS TRUE -VALIDATION_STRINGENCY LENIENT -MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 1000 -REMOVE_DUPLICATES TRUE

#######################################

## Identifying gene regions on prodigal output:
   
# Script adapted from https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/in-house/prokkagff2gtf.sh
# Ensure script saved in working directory (i.e. LINK)
sh "$LINK"/prodigalgff2gtf.sh "$MetaMAG"/"$MG"_prodigal/"$MG".gff  > "$MetaMAG"/"$MG"_map.gtf

# HTSeq (Analysing HTS data with python).
# htseq-count (how many reads map to each feature) --stranded=no -r (order) -t (feature type) -f (format) <AlignmentBamFiles> <GffFile> > <OUTPUT>
source activate htseq
htseq-count --stranded=no -r pos -t CDS -f bam "$MetaMAG"/"$MG"_picard/"$MG"_map_markdup.bam "$MetaMAG"/"$MG"_map.gtf > "$MetaMAG"/"$MG".count

#######################################

## Normalise by Transcripts Per Million (TPM) - i.e. reads per million with gene length accounted for:

# Extract only start, stop, and gene name fields from file, then remove 'gene_id' string, print gene names followed by length of gene, change separator to tab and store results in .genelengths file
cut -f 4,5,9 "$MetaMAG"/"$MG"_map.gtf | sed 's/gene_id //g' | gawk '{print $3,$2-$1+1}' | tr ' ' '\t' > "$MetaMAG"/"$MG".genelengths

# tpm_table.py script 
# python tpm_table.py -n $SAMPLE -c $SAMPLE.count -i <(echo -e "$SAMPLE\t100") -l $SAMPLE.genelengths > $SAMPLE.tpm 
wget https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/in-house/tpm_table.py -P "$MetaMAG"/
module load pandas-0.24.2
python "$MetaMAG"/tpm_table.py -n $MG -c "$MetaMAG"/"$MG".count -i <(echo -e "$MG\t150") -l "$MetaMAG"/"$MG".genelengths > "$MetaMAG"/"$MG".tpm

## Modify TSV Files:

# Add sample name to .tpm file.
sed -i "s/$/\t$MG/" "$MetaMAG"/"$MG".tpm
mkdir "$LINK"/MetaMAG
cp "$MetaMAG"/"$MG".tpm "$LINK"/MetaMAG/

# Add sample name to .faa files:
sed -i "s/>/>"$MG"_/" "$MetaMAG"/"$MG"_prodigal/"$MG".faa
cp "$MetaMAG"/"$MG"_prodigal/"$MG".faa "$LINK"/MetaMAG/

## END OF PART 1 ##

########################################