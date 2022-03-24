#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts m:o: flag
do
	case "${flag}" in
		m) MG=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "Metagenome Name (No spaces or special characters): $MG"; 
# Note MG must be one word and contain no special characters (e.g. MG or MetagenomeName)
echo "metaMAG Output Directory: $OUTPUT"


echo "###### metaMAG_gene module: Updated 24/03/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

echo "Intergrate All GFs and Kegg Orthology (KO) K Numbers with TPM Data:"

# Only Annotated GFs:
awk -F "\t" '$2~/^K/' OFS="\t" "$metaMAG"/Kofam_Scan/Kofam_Scan_Results.txt > "$metaMAG"/Kofam_Scan/Kofam_Scan_Results_K.txt

TPMOutput="$metaMAG"/metaMAG/

Rscript TPM.R "$metaMAG"/metaMAG/Combined_TPM.tsv "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster.tsv "$metaMAG"/Kofam_Scan/Kofam_Scan_Results_K.txt "$TPMOutput"

# Output Files: ClusterCount.tsv GeneTPM.tsv TotalTPM.tsv PercentTPM.tsv

echo "### END OF MODULE ###"

###########################################