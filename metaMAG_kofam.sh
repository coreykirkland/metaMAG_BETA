#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts a:k:p:t:o: flag
do
	case "${flag}" in
		k) KOLIST=${OPTARG};;
		p) PROFILE=${OPTARG};;
		t) THREADS=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "Metagenome Name (No spaces or special characters): $MG"; 
# Note MG must be one word and contain no special characters (e.g. MG or MetagenomeName)
echo "Number of Threads: $THREAD";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_kofam module: Updated 28/11/21 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG

########################################

exec_annotation --cpu "$THREADS" -f mapper -k "$KOLIST" -p "$PROFILE" -o "$metaMAG"/Kofam_Scan/ "$metaMAG"/metaMAG/mmseqs2/test_cluster_repseq.fasta

echo "### END OF MODULE ###"

###########################################
