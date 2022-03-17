#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts m:c:a:j:o: flag
do
	case "${flag}" in
		m) MG=${OPTARG};;
		c) CONTIG=${OPTARG};;
		a) ALIGNMENT=${OPTARG};;
		j) JARVA=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "Metagenome Name (No spaces or special characters): $MG"; 
# Note MG must be one word and contain no special characters (e.g. MG or MetagenomeName)
echo "Contig File: $CONTIG";
echo "Alignment File: $ALIGNMENT";
echo "Jarva PATH: $JARVA";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_setup module: Updated 17/03/22 ######"

mkdir "$OUTPUT"/metaMAG/
metaMAG="$OUTPUT"/metaMAG/

mkdir "$metaMAG"/"$MG"/
MG_DIR="$metaMAG"/"$MG"/

###################################

echo "Annotate Metagenome Assembly with prodigal:"

# Make prodigal directory.
mkdir "$MG_DIR"/"$MG"_prodigal/

# prodigal <InputFile> <NucleotideOuput> <AminoAcidOutput> <GffOutput> -p meta 
prodigal -i "$CONTIG" -d "$MG_DIR"/"$MG"_prodigal/"$MG".fna -a "$MG_DIR"/"$MG"_prodigal/"$MG".faa -o "$MG_DIR"/"$MG"_prodigal/"$MG".gff -p meta -f gff

grep ">" "$MG_DIR"/"$MG"_prodigal/"$MG".faa | wc -l > "$MG_DIR"/"$MG"_prodigal/"$MG"_Gene_Total.txt

######################################

echo "Alignment Statistics and Remove Duplicate Reads with Picard"

mkdir "$MG_DIR"/"$MG"_picard

# Alignment Stats - Picard CollectAlignmentSummaryMetrics. See http://broadinstitute.github.io/picard/picard-metric-definitions.html#AlignmentSummaryMetrics for table column definitions.
java -Xms2g -Xmx32g -jar "$JARVA" CollectAlignmentSummaryMetrics R="$CONTIG" I="$ALIGNMENT" O="$MG_DIR"/"$MG"_picard/"$MG"_Alignment_Stats.txt
   
# Identify duplicate reads
# <BamInput> <BamOutput> \ METRICS_FILE=<File> (File to write duplication metrics to) \ MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=<File> (Max no. file handles to keep open when spilling read ends to disk) REMOVE_DUPLICATES=TRUE (TRUE = do not write duplicates to output file instead of writing them with appropriate flags set)
java -Xms2g -Xmx32g -jar "$JARVA" MarkDuplicates INPUT="$ALIGNMENT" OUTPUT="$MG_DIR"/"$MG"_picard/"$MG"_map_markdup.bam \
METRICS_FILE="$MG_DIR"/"$MG"_picard/"$MG"_map_markdup.metrics AS=TRUE VALIDATION_STRINGENCY=LENIENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 REMOVE_DUPLICATES=TRUE

# New syntax? Needs testing.
# java -Xms2g -Xmx32g -jar /opt/software/uoa/2019/spack/opt/spack/linux-centos7-x86_64/gcc-9.1.0/picard-2.19.0-uc3lvtta7rlpyv2lpvmq347bdrzhx76r/bin/picard.jar
#MarkDuplicates -INPUT /uoa/home/s02ck0/sharedscratch/Sample_10_MG2/Sample_10_MG2.map.sorted.bam -OUTPUT /uoa/home/s02ck0/sharedscratch/Sample_10_MG2/Sample_10_MG2.map.markdup.bam -METRICS_FILE /uoa/home/s02ck0/sharedscratch/Sample_10_MG2/Sample_10_MG2.map.markdup.metrics -AS TRUE -VALIDATION_STRINGENCY LENIENT -MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 1000 -REMOVE_DUPLICATES TRUE

#######################################

echo "Identifying Gene Regions on prodigal Output:"
   
# Script adapted from https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/in-house/prokkagff2gtf.sh
# Ensure script saved in working directory
sh prodigalgff2gtf.sh "$MG_DIR"/"$MG"_prodigal/"$MG".gff  > "$MG_DIR"/"$MG"_map.gtf

# HTSeq (Analysing HTS data with python).
# htseq-count (how many reads map to each feature) --stranded=no -r (order) -t (feature type) -f (format) <AlignmentBamFiles> <GffFile> > <OUTPUT>
htseq-count --stranded=no -r pos -t CDS -f bam "$MG_DIR"/"$MG"_picard/"$MG"_map_markdup.bam "$MG_DIR"/"$MG"_map.gtf > "$MG_DIR"/"$MG".count

#######################################

echo "Normalise by Transcripts Per Million (TPM)" # i.e. reads per million with gene length accounted for:

# Extract only start, stop, and gene name fields from file, then remove 'gene_id' string, print gene names followed by length of gene, change separator to tab and store results in .genelengths file
cut -f 4,5,9 "$MG_DIR"/"$MG"_map.gtf | sed 's/gene_id //g' | gawk '{print $3,$2-$1+1}' | tr ' ' '\t' > "$MG_DIR"/"$MG".genelengths

# tpm_table.py script from https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/in-house/tpm_table.py
# python tpm_table.py -n $SAMPLE -c $SAMPLE.count -i <(echo -e "$SAMPLE\t100") -l $SAMPLE.genelengths > $SAMPLE.tpm 
python tpm_table.py -n $MG -c "$MG_DIR"/"$MG".count -i <(echo -e "$MG\t150") -l "$MG_DIR"/"$MG".genelengths > "$MG_DIR"/"$MG".tpm

echo "Modify TPM and FAA Files:"

# Add sample name to .tpm file.
sed -i "s/$/\t$MG/" "$MG_DIR"/"$MG".tpm
mkdir "$metaMAG"/metaMAG
cp "$MG_DIR"/"$MG".tpm "$metaMAG"/metaMAG/

# Add sample name to .faa files:
sed -i "s/>/>"$MG"_/" "$MG_DIR"/"$MG"_prodigal/"$MG".faa
cp "$MG_DIR"/"$MG"_prodigal/"$MG".faa "$metaMAG"/metaMAG/

echo "### END OF MODULE ###"

########################################