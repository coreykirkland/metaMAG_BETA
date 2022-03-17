#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts m:a:c:t:o: flag
do
	case "${flag}" in
		m) MG=${OPTARG};;
		a) ALIGNMENT=${OPTARG};;
		c) CONTIG=${OPTARG};;
		t) THREADS=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "Metagenome Name (No spaces or special characters): $MG"; 
# Note MG must be one word and contain no special characters (e.g. MG or MetagenomeName)
echo "Alignment File: $ALIGNMENT";
echo "Contig File : $CONTIG";
echo "Number of Threads: $THREAD";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_strain module: Updated 17/03/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/
MG_DIR="$metaMAG"/"$MG"/

###########################################

echo "Running inStrain Program with Alignment, Contig and FNA files:"

# Make new directories:
mkdir "$MG_DIR"/"$MG"_inStrain

# Variables:
inStrainDIR="$MG_DIR"/"$MG"_inStrain

# inStrain:            
inStrain profile "$ALIGNMENT" "$CONTIG" -o "$inStrainDIR"/"$MG"_output.IS -p "$THREADS" -g "$MG_DIR"/"$MG"_prodigal/"$MG".fna --skip_genome_wide --skip_plot_generation --debug --skip_mm_profiling

###########################################

# SNV per Gene and Gene Family:

## Note: GF/Cluster_Rep name modified to remove "GeneID=n". Therefore, GF name different in this section to all other sections. Still contains contig and gene number. ##

# Modify inStrain Gene Output:
gzip -d "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv.gz

sed -i "1 s/$/\tMG/" "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv
sed -i "2,$ s/$/\t$MG/" "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv

# Modify Final_Cluster_Multi_GF.tsv (containing only GFs containing more than one gene):

sed "s/_/\t/4" "$metaMAG"/metaMAG/mmseqs2/Final_Cluster_Multi_GF.tsv > "$metaMAG"/metaMAG/mmseqs2/cluster3.tsv
sed -i "s/_/\t/8" "$metaMAG"/metaMAG/mmseqs2/cluster3.tsv
cut -f 1,3 "$metaMAG"/metaMAG/mmseqs2/cluster3.tsv > "$metaMAG"/metaMAG/mmseqs2/Final_Cluster_Multi_GF_Modified.tsv

SNVOutput="$MG_DIR"/"$MG"_

# SNV.R Script:
Rscript SNV.R "$inStrainDIR"/"$MG"_output.IS/output/"$MG"_output.IS_gene_info.tsv "$metaMAG"/metaMAG/mmseqs2/Final_Cluster_Multi_GF_Modified.tsv "$MG_DIR"/"$MG"_MergedMAG.tsv "$SNVOutput"

# Output Files: "$MG"_SNVs.tsv "$MG"_NucDiv.tsv "$MG"_pNpS.tsv "$MG"_MergedDfNaOmit.tsv "$MG"_GeneSNV_MAG.tsv

echo "### END OF MODULE ###"

###########################################