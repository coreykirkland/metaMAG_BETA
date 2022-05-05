#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts t:g:k:o: flag
do
	case "${flag}" in
		t) HEATMAPTAXON=${OPTARG};;
		g) GFPREFIX=${OPTARG};;
		k) KOPREFIX=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG: $0"
echo "Heatmap Order: $HEATMAPTAXON";
echo "GF Output Prefix: $GFPREFIX";
echo "KO Output Prefix: $KOPREFIX";
echo "metaMAG Output Directory: $OUTPUT"


echo "###### metaMAG_visualisation_heatmap module: Updated 05/05/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

###################################

# Rscript output:
ROutputGF="$metaMAG"/metaMAG/Genome_Visualisation/"$GFPREFIX"_
ROutputKO="$metaMAG"/metaMAG/Genome_Visualisation/"$KOPREFIX"_

# Rscript:
Rscript GenomeVisualisationHeatmap.R "$metaMAG"/metaMAG/Genome_Visualisation/MergedGF.tsv "$metaMAG"/metaMAG/Genome_Visualisation/MergedKO.tsv "$HEATMAPTAXON" "$ROutputGF" "$ROutputKO"

# Outputs: HeatmapGF.tsv HeatmapGF.pdf HeatmapKO.tsv HeatmapKO.pdf

echo "### END OF MODULE ###"