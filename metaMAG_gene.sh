#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts m:k:o flag
do
	case "${flag}" in
		m) MG=${OPTARG};;
		k) KOFAM=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "Metagenome Name (No spaces or special characters): $MG"; 
# Note MG must be one word and contain no special characters (e.g. MG or MetagenomeName)
echo "KOFAM File: $KOFAM";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_gene module: Updated 28/11/21 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

echo "Intergrate All GFs and Kegg Orthology (KO) K Numbers with TPM Data:"

# Only Annotated GFs:
grep "K" "$KOFAM" > "$metaMAG"/Kofam_Scan_Output

TPMOutput="$metaMAG"/metaMAG/

Rscript TPM.R "$metaMAG"/metaMAG/Combined_TPM.tsv "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster.tsv "$metaMAG"/Kofam_Scan_Output "$TPMOutput"

# Output Files: ClusterCount.tsv GeneTPM.tsv TotalTPM.tsv PercentTPM.tsv

echo "### END OF MODULE ###"

###########################################