#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts k:f:o: flag
do
	case "${flag}" in
		k) BARCHARTKO=${OPTARG};;
		f) FILENAME=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG: $0"
echo "Barchat KO: $BARCHARTKO"; 
echo "File Name Prefix: $FILENAME";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_visualisation_barchart module: Updated 01/05/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

###################################

# Rscript output:
ROutput="$metaMAG"/metaMAG/Genome_Visualisation/"$FILENAME"_

# Rscript:
Rscript GenomeVisualisationBarchart.R "$metaMAG"/metaMAG/Genome_Visualisation/MergedKOAll.tsv "$BARCHARTKO" "$ROutput"

# Outputs: BarchartKO.tsv BarchartKO.tsv
