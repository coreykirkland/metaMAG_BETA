#!/bin/bash
	set -e
	set -u
	set -o pipefail

while getopts m:b:o: flag
do
	case "${flag}" in
		m) MG=${OPTARG};;
		b) BIN=${OPTARG};;
		o) OUTPUT=${OPTARG};;
	esac
done

echo "metaMAG Module: $0"
echo "Metagenome Name (No spaces or special characters): $MG"; 
# Note MG must be one word and contain no special characters (e.g. MG or MetagenomeName)
echo "Bin Directory: $BIN";
echo "metaMAG Output Directory: $OUTPUT"

#test -d some_directory ; echo $? # is this a directory? 
#test -f some_file.txt ; echo $? # is this a file?
#test -r some_file.txt ; echo $? $ is this file readable?

echo "###### metaMAG_genome module: Updated 17/03/22 ######"

# Variables:
metaMAG="$OUTPUT"/metaMAG/
MG_DIR="$metaMAG"/"$MG"/

###########################################

# Modify bin files with bin name - for a given MG.
mkdir "$MG_DIR"/"$MG"_Renamed_Bin

# cd to bin directory:
cd "$BIN"

for bin in *.fa; do
	sed "s/>/>"$MG"_"$bin"_/" $bin > "$MG_DIR"/"$MG"_Renamed_Bin/"$MG"_"$bin"_renamed.fa
done

cd "$OUTPUT"

# Concatenate all renamed bin files into one file
cat "$MG_DIR"/"$MG"_Renamed_Bin/*_renamed.fa > "$MG_DIR"/"$MG"_Renamed_Bin/"$MG"_combined_bin.fa

# Create table with fasta headers from renamed bins
grep '>' "$MG_DIR"/"$MG"_Renamed_Bin/"$MG"_combined_bin.fa | sed "s/>//" > "$MG_DIR"/"$MG"_BIN_Table.tsv

# Modify GFF files and create table
grep -v "#" "$MG_DIR"/"$MG"_prodigal/"$MG".gff | cut -f 1,9 | sed "s/;/\t/" | sed "s/_/\t/2" | cut -f 1,3 | sed "s/ID=//" > "$MG_DIR"/"$MG"_GFF_Table.tsv

# Filter PercentTPM table by MG:
awk -v awkvar="$MG" '$3 == awkvar' "$metaMAG"/metaMAG/PercentTPM.tsv > "$metaMAG"/metaMAG/"$MG"_PercentTPM.tsv

# RScript: Merge MAG_Table.tsv, MAG_Table_Updated.tsv, and PercentTPM.tsv
MAGOutput="$metaMAG"/metaMAG/"$MG"_

Rscript MAGPercent.R "$MG_DIR"/"$MG"_BIN_Table.tsv "$MG_DIR"/"$MG"_GFF_Table.tsv "$metaMAG"/metaMAG/"$MG"_PercentTPM.tsv "$MAGOutput"

# Outputs: MAGPercentGF.tsv MAGPercentKO.tsv MergedMAG.tsv MAGPercent.tsv

echo "### END OF MODULE ###"

###########################################