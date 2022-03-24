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


echo "###### metaMAG_kofam module: Updated 23/03/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG

########################################

mkdir "$metaMAG"/Kofam_Scan/

exec_annotation --cpu "$THREADS" -f mapper -k "$KOLIST" -p "$PROFILE" -o "$metaMAG"/Kofam_Scan/Kofam_Scan_Results.txt --tmp-dir "$metaMAG"/Kofam_Scan/tmp  "$metaMAG"/metaMAG/mmseqs2/test_cluster_repseq.fasta

echo "### END OF MODULE ###"

###########################################