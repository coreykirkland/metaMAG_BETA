#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts o flag
do
	case "${flag}" in
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG: $0"
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_visualisation_setup module: Updated 20/02/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/

###################################

# Create new directory:
mkdir "$metaMAG"/metaMAG/Genome_Visualisation/

# Combine MAGPercentGF from all MGs:
cat "$metaMAG"/metaMAG/*_MAGPercentGF.tsv > "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentGF1

# Combine MAGPercentKO from all MGs:
cat "$metaMAG"/metaMAG/*_MAGPercentKO.tsv > "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentKO1

# Rscript Output:
GV_Output="$metaMAG"/metaMAG/Genome_Visualisation/

# Rscript:
Rscript GenomeVisualisationSetup.R "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentGF1 "$metaMAG"/metaMAG/Genome_Visualisation/Combined_MAGPercentKO1 MAG_Taxonomy.tsv SelectedKOs.tsv AllKOs.tsv "$OUTPUT"

# Outputs: MergedGF.tsv MergedKO.tsv MergedGFAll.tsv MergedKOAll.tsv
