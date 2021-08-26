#!/bin/R Rscript

# title: "MAGs" Updated: 26/8/21

# commmandArgs:
Args = commandArgs(TRUE)
MAGTable <- Args[1]
MAGTableUpdated <- Args[2]
PercentTPM <- Args[3]
Output <- Args[4]

# Load Library:
library(tidyr)
library(dplyr)

# Make Dataframe:
MAGTable <- read.delim(MAGTable, header = FALSE, sep = "\t", col.names = "Col1") # from binning
MAGTableUpdated <- read.delim(MAGTableUpdated, header = FALSE, sep = "\t", col.names = c("Contig", "GeneID")) # GFF

# Modify MAGTable:
MAGTable <- separate(MAGTable, Col1, c("MG","bin", "k", "contig", "length", "l.no", "cov", "c.no"),sep = "_")
MAGTable <- data.frame(MG = MAGTable$MG, Bin = MAGTable$bin, Contig = paste(MAGTable$k, MAGTable$contig, sep = "_"))

# Modify MAGTableUpdated:
MAGTableUpdated <- separate(MAGTableUpdated, Contig, c("k", "contig", "length", "l.no", "cov", "cov.no"), sep = "_")
MAGTableUpdated <- data.frame(Contig = paste(MAGTableUpdated$k, MAGTableUpdated$contig, sep = "_"), GeneID = MAGTableUpdated$GeneID)

# Merge MAGTable and MAGTableUpdated:
MergedMAG <- merge(MAGTable, MAGTableUpdated, by.x = "Contig", by.y = "Contig", all.x = FALSE, all.y = FALSE)
MergedMAG <- unique(MergedMAG)
MergedMAG <- data.frame(MergedMAG, MG_GeneID = paste(MergedMAG$MG, MergedMAG$GeneID, sep = "_"))

# PercentTPM Table:
PercentTPM <- read.delim(PercentTPM, sep = "\t", header = TRUE)
PercentTPM <- data.frame(PercentTPM, ClusterRep_MG = paste(PercentTPM$ClusterRep, PercentTPM$MG, sep = "_"))

# Merge and set NA to Unbinned:
MAGPercent <- merge(MergedMAG, PercentTPM, by.x = "MG_GeneID", by.y = "MG_GeneID", all.x = FALSE, all.y = TRUE)
MAGPercent <- unique(MAGPercent)
MAGPercent$Bin <- as.character(MAGPercent$Bin)
MAGPercent$Bin[is.na.data.frame(MAGPercent$Bin)] <- "Unbinned"

# Calculate % of Binned and Unbinned for GF:
MAGPercentGF <- aggregate(x = MAGPercent$GFPercent, by = list(MAGPercent$ClusterRep_MG, MAGPercent$MG.y, MAGPercent$Bin), FUN = sum)
MAGPercentGF <- data.frame(ClusterRep_MG = MAGPercentGF$Group.1, MG_Bin = paste(MAGPercentGF$Group.2, MAGPercentGF$Group.3, sep = "_"), GFPercent = MAGPercentGF$x)

# Additional Script: Calculate % of Binned and Unbinned for KO
MAGPercentKO <- aggregate(x = MAGPercent$KOPercent, by = list(MAGPercent$KO, MAGPercent$MG.y, MAGPercent$Bin), FUN = sum)
MAGPercentKO <- data.frame(KO = MAGPercentKO$Group.1, MG_Bin = paste(MAGPercentKO$Group.2, MAGPercentKO$Group.3, sep = "_"), KOPercent = MAGPercentKO$x)

# Write Tables:
write.table(MAGPercentGF, file = paste(Output, 'MAGPercentGF.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)
write.table(MAGPercentKO, file = paste(Output, 'MAGPercentKO.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)
write.table(MergedMAG, file = paste(Output, 'MergedMAG.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)
write.table(MAGPercent, file = paste(Output, 'MAGPercent.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)