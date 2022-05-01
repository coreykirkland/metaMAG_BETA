#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts k:b:o: flag
do
	case "${flag}" in
		k) BARCHARTKO=${OPTARG};;
		b) BARCHARTFILL=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG: $0"
echo "Barchat KO: $BARCHARTKO"; 
echo "Barchart Taxon: $BARCHARTFILL";
echo "metaMAG Output Directory: $OUTPUT"


echo "###### metaMAG_visualisation_barchart module: Updated 30/04/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

###################################

# Rscript output:
ROutput="$metaMAG"/metaMAG/Genome_Visualisation/"$BARCHARTKO"_"$BARCHARTFILL"_

# Rscript:
Rscript GenomeVisualisationBarchart.R "$metaMAG"/metaMAG/Genome_Visualisation/MergedKOAll.tsv "$BARCHARTKO" "$BARCHARTFILL" "$ROutput"

# Outputs: BarchartKO.tsv BarchartKO.tsv

echo "### END OF MODULE ###"