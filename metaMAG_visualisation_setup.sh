#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts o: flag
do
	case "${flag}" in
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG: $0"
echo "metaMAG Output Directory: $OUTPUT"


echo "###### metaMAG_visualisation_setup module: Updated 30/04/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

###################################

# Create new directory:
mkdir "$metaMAG"/metaMAG/Genome_Visualisation/

# Combine MAGPercentGF from all MGs:
cat "$metaMAG"/metaMAG/*_MAGPercentGF.tsv > "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentGF.tsv

# Combine MAGPercentKO from all MGs:
cat "$metaMAG"/metaMAG/*_MAGPercentKO.tsv > "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentKO.tsv

# Remove ".fa" from MAG names:
sed "s/.fa//g" -i "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentGF.tsv

sed "s/.fa//g" -i "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentKO.tsv

# Rscript Output:
GV_Output="$metaMAG"/metaMAG/Genome_Visualisation/

# Rscript:
Rscript GenomeVisualisationSetup.R "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentGF.tsv "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentKO.tsv MAG_Taxonomy.tsv SelectedKOs.tsv AllKOs.tsv "$GV_Output"

# Outputs: MergedGF.tsv MergedKO.tsv MergedGFAll.tsv MergedKOAll.tsv

echo "### END OF MODULE ###"