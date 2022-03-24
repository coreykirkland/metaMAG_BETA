#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts t:p:o: flag
do
	case "${flag}" in
		t) HEATMAPTAXON=${OPTARG};;
		p) HEATMAPVALUE=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG: $0"
echo "Heatmap Order: $HEATMAPTAXON";
echo "Heatmap Percentage: $HEATMAPVALUE";
echo "metaMAG Output Directory: $OUTPUT"


echo "###### metaMAG_visualisation_heatmap module: Updated 17/03/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

###################################

# Rscript output:
ROutput="$metaMAG"/metaMAG/Genome_Visualisation/

# Rscript:
Rscript GenomeVisualisationHeatmap.R "$metaMAG"/metaMAG/Genome_Visualisation/MergedGF.tsv "$metaMAG"/metaMAG/Genome_Visualisation/MergedKO.tsv "$HEATMAPTAXON" "$HEATMAPVALUE" "$ROutput"

# Outputs: HeatmapGF.tsv HeatmapGF.pdf HeatmapKO.tsv HeatmapKO.pdf