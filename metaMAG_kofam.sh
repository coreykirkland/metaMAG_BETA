#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts k:p:t:o: flag
do
	case "${flag}" in
		k) KOLIST=${OPTARG};;
		p) PROFILE=${OPTARG};;
		t) THREADS=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "KO List: $KOLIST"
echo "Profile: $PROFILE"
echo "Number of Threads: $THREADS"
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_kofam module: Updated 22/03/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG

########################################

mkdir "$metaMAG"/Kofam_Scan/

exec_annotation --cpu "$THREADS" -f mapper -k "$KOLIST" -p "$PROFILE" -o "$metaMAG"/Kofam_Scan/ "$metaMAG"/metaMAG/mmseqs2/test_cluster_repseq.fasta

echo "### END OF MODULE ###"

###########################################