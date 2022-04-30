#!/bin/R Rscript

# title: "MAGs" Updated: 30/04/22

# commmandArgs:
Args = commandArgs(TRUE)
MAGTable <- Args[1]
MAGTableUpdated <- Args[2]
PercentTPM <- Args[3]
Output <- Args[4]

# Load Library:
library(tidyr)
library(dplyr)

# Read tables:
MAGTable <- read.delim(MAGTable, header = FALSE, sep = "\t", col.names = "Col1") # from binning
MAGTableUpdated <- read.delim(MAGTableUpdated, header = FALSE, sep = "\t", col.names = c("Contig", "GeneID")) # GFF
PercentTPM <- read.delim(PercentTPM, sep = "\t", header = TRUE, col.names = c("MG_KO","GF","MG","GF_Member","MG_GeneID","TPM","TotalTPM","Percent_GF","KO","TotalTPM_KO","Percent_KO")) # PercentTPM.tsv

# Modify MAGTable:
MAGTable <- separate(MAGTable, Col1, c("MG","bin", "k", "contig", "length", "l.no", "cov", "c.no"), sep = "_")
MAGTable <- data.frame(MG = MAGTable$MG, Bin = MAGTable$bin, Contig = paste(MAGTable$k, MAGTable$contig, sep = "_"))

# Merge MAGTable and MAGTableUpdated:
MergedMAG <- merge(MAGTable, MAGTableUpdated, by = "Contig", all.x = FALSE, all.y = FALSE)
MergedMAG <- unique(MergedMAG)
MergedMAG <- data.frame(MergedMAG, MG_GeneID = paste(MergedMAG$MG, MergedMAG$GeneID, sep = "_"))
write.table(MergedMAG, file = paste(Output, 'MergedMAG.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)

# Merge with PercentTPM:
MAGPercent <- merge(PercentTPM, MergedMAG, by = "MG_GeneID", all.x = TRUE, all.y = FALSE)
MAGPercent <- unique(MAGPercent)
MAGPercent$Bin <- as.character(MAGPercent$Bin)
MAGPercent$Bin[is.na.data.frame(MAGPercent$Bin)] <- "Unbinned"
write.table(MAGPercent, file = paste(Output, 'MAGPercent.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)

# Calculate percentages for GF:
MAGPercentGF <- aggregate(x = MAGPercent$Percent_GF, by = list(MAGPercent$GF, MAGPercent$MG.x, MAGPercent$Bin, MAGPercent$MG_KO), FUN = sum)
MAGPercentGF <- data.frame(GF = MAGPercentGF$Group.1, MG = MAGPercentGF$Group.2, MAG = MAGPercentGF$Group.3, MG_KO = MAGPercentGF$Group.4, GFPercent = MAGPercentGF$x)
write.table(MAGPercentGF, file = paste(Output, 'MAGPercentGF.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)

# Calculate percentages for KO:
MAGPercentKO <- aggregate(x = MAGPercent$Percent_KO, by = list(MAGPercent$KO, MAGPercent$MG.x, MAGPercent$Bin), FUN = sum)
MAGPercentKO <- data.frame(KO = MAGPercentKO$Group.1, MG = MAGPercentKO$Group.2, MAG = MAGPercentKO$Group.3, KOPercent = MAGPercentKO$x)
write.table(MAGPercentKO, file = paste(Output, 'MAGPercentKO.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)
