#!/bin/R

# GenomeVisualisationSetup.R

# commmandArgs:
Args = commandArgs(TRUE)
GFPercent <- Args[1]
KOPercent <- Args[2]
MAGTaxonomy <- Args[3]
SelectedKOs <- Args[4]
AllKOs <- Args[5]
Output <- Args[6]

# Load Libraries:
library(tidyr)
library(dplyr)

# Read Data:
GFPercent <- read.delim(GFPercent, header = TRUE, sep = "\t")
KOPercent <- read.delim(KOPercent, header = TRUE, sep = "\t")
MAGTaxonomy <- read.delim(MAGTaxonomy, header = TRUE, sep = "\t")
SelectedKOs <- read.delim(SelectedKOs, header = TRUE, sep = "\t")
AllKOs <- read.delim(AllKOs, header = TRUE, sep = "\t")

# Merge Data - MAGTaxonomy (All) and KOs (Selected):

# GFPercent 
MergedGF <- merge(GFPercent, MAGTaxonomy, by = "MAG", all.x = TRUE, all.y = FALSE)
MergedGF <- separate(MergedGF, MG_KO, c("MG", "KO"), sep = "_")
MergedGF <- merge(MergedGF, SelectedKOs, by = "KO", all = FALSE)
MergedGF <- unique(MergedGF)
write.table(MergedGF, file = paste(Output, 'MergedGF.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)

# KOPercent
MergedKO <- merge(KOPercent, MAGTaxonomy, by = "MAG", all.x = TRUE, all.y = FALSE)
MergedKO <- merge(MergedKO, SelectedKOs, by = "KO", all = FALSE)
MergedKO <- unique(MergedKO)
write.table(MergedKO, file = paste(Output, 'MergedKO.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)

# Merge Data - MAGTaxonomy (All) and KOs (All):

# GFPercent
MergedGFAll <- merge(GFPercent, MAGTaxonomy, by = "MAG", all.x = TRUE, all.y = FALSE)
MergedGFAll <- separate(MergedGFAll, MG_KO, c("MG", "KO"), sep = "_")
MergedGFAll <- merge(MergedGFAll, AllKOs, by = "KO", all = FALSE)
MergedGFAll <- unique(MergedGFAll)
write.table(MergedGFAll, file = paste(Output, 'MergedGFAll.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)

# KOPercent
MergedKOAll <- merge(KOPercent, MAGTaxonomy, by = "MAG", all.x = TRUE, all.y = FALSE)
MergedKOAll <- merge(MergedKOAll, AllKOs, by = "KO", all = FALSE)
MergedKOAll <- unique(MergedKOAll)
write.table(MergedKOAll, file = paste(Output, 'MergedKOAll.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)
