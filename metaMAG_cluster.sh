#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts t:o: flag
do
	case "${flag}" in
		t) THREADS=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "Number of Threads: $THREADS";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_cluster module: Updated 17/03/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

########################################

echo "Concatenate All TPM Files:"
cat "$metaMAG"/metaMAG/*.tpm > "$metaMAG"/metaMAG/Combined_TPM.tsv

echo "Concatenate All AA Files then Modify Header:"
cat "$metaMAG"/metaMAG/*.faa > "$metaMAG"/metaMAG/Combined_AA.fasta

# Modify fasta header - now includes contig and gene ID:
cut "$metaMAG"/metaMAG/Combined_AA.fasta -f 4,5,6,7 -d "_" --complement | cut -f 1,9 -d " " | cut -f 1 -d ";" | sed "s/ ID=/_GeneID=/" > "$metaMAG"/metaMAG/Combined_AA_1.fasta

echo "Make Directories:"
mkdir "$metaMAG"/metaMAG/mmseqs2
mkdir "$metaMAG"/metaMAG/mmseqs2/allMG_AA_DB_tmp

echo "Clustering AA Files with MMSeqs2:"

# Create DB (convert .faa files into MMseqs2 database format).
mmseqs createdb "$metaMAG"/metaMAG/Combined_AA_1.fasta "$metaMAG"/metaMAG/mmseqs2/allMG_AA_DB

# Cluster using cascaded clustering (clusters sequences in DB file by similarity).
# mmseqs cluster --threads (n) --cov-mode (0 = bidirectional coverage) -c (0.8 = 80%) --min-seq-id (target sequence identity) <DatabaseFile> <AaClusterOutputFile> <TpmOutputFile>
mmseqs cluster --threads "$THREADS" --cov-mode 0 -c 0.8 --min-seq-id 0.35 "$metaMAG"/metaMAG/mmseqs2/allMG_AA_DB "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster "$metaMAG"/metaMAG/mmseqs2/allMG_AA_DB_tmp

# Create tsv file (mmseqs createtsv DB DB DB_clu DB_clu.tsv).
mmseqs createtsv --threads "$THREADS" "$metaMAG"/metaMAG/mmseqs2/allMG_AA_DB "$metaMAG"/metaMAG/mmseqs2/allMG_AA_DB "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster.tsv

# Extract representative fasta from each clustering result.
# mmseqs createsubdb DB_clu DB DB_clu_rep
mmseqs createsubdb "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster "$metaMAG"/metaMAG/mmseqs2/allMG_AA_DB "$metaMAG"/metaMAG/mmseqs2/test_cluster_repseq
# mmseqs convert2fasta DB_clu_rep DB_clu_rep.fasta
mmseqs convert2fasta "$metaMAG"/metaMAG/mmseqs2/test_cluster_repseq "$metaMAG"/metaMAG/mmseqs2/test_cluster_repseq.fasta

echo "Calculating MMSeqs2 Statistics:"

MmseqOutput="$metaMAG"/metaMAG/
Rscript Mmseqs2Stats.R "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster.tsv "$MmseqOutput"

# Output: MmseqsStats.tsv and MmseqsHistogram.pdf

# Remove singletons from cluster.tsv file:
awk -F "\t" '{print $2,$1}' OFS="\t" "$metaMAG"/metaMAG/mmseqs2/allMG_AA_cluster.tsv > "$metaMAG"/metaMAG/mmseqs2/cluster.tsv

sort -k 2 "$metaMAG"/metaMAG/mmseqs2/cluster.tsv | uniq -f 1 -D > "$metaMAG"/metaMAG/mmseqs2/cluster1.tsv 

awk -F "\t" '{print $2,$1}' OFS="\t" "$metaMAG"/metaMAG/mmseqs2/cluster1.tsv > "$metaMAG"/metaMAG/mmseqs2/Final_Cluster_Multi_GF.tsv

# Final_Cluster_Multi_GF.tsv contains only GFs with multiple genes.

echo "### END OF MODULE ###"

###########################################
