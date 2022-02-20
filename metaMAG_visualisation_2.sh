#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts k:b:t:p:o flag
do
	case "${flag}" in
		k) BARCHARTKO=${OPTARG};;
		b) BARCHARTFILL=${OPTARG};;
		t) HEATMAPTAXON=${OPTARG};;
		p) HEATMAPVALUE=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG: $0"
echo "Barchat KO: $BARCHARTKO"; 
echo "Barchart Taxon: $BARCHARTFILL";
echo "Heatmap Order: $HEATMAPTAXON";
echo "Heatmap Percentage: $HEATMAPVALUE";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_visualisation_2 module: Updated 20/02/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

###################################

# Rscript output:
ROutput="$metaMAG"/metaMAG/Genome_Visualisation/

# Rscript:
Rscript Genome_Visualisation2.R "$metaMAG"/metaMAG/Genome_Visualisation/MergedKOAll.tsv "$metaMAG"/metaMAG/Genome_Visualisation/MergedGF.tsv "$metaMAG"/metaMAG/Genome_Visualisation/MergedKO.tsv "$BARCHARTKO" "$BARCHARTFILL" "$HEATMAPTAXON" "$HEATMAPVALUE" "$ROutput"

# Outputs: BarchartKO.tsv BarchartKO.tsv HeatmapGF.tsv HeatmapGF.pdf HeatmapKO.tsv HeatmapKO.pdf