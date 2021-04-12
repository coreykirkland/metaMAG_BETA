#!/bin/R Rscript

# title: "MAGsGF" Updated: 1/4/21

# commmandArgs:
Args = commandArgs(TRUE)
MAGTable <- Args[1]
MAGTableUpdated <- Args[2]
PercentTPM <- Args[3]
MGName <- Args [4]
Output <- Args[5]

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
MergedMAG <- data.frame(MergedMAG, MG_GeneID = paste(MergedMAG$MG, MergedMAG$GeneID, sep = "_"))

# PercentTPM Table:
PercentTPM <- read.delim(PercentTPM, header = TRUE, sep = "\t")
PercentTPM <- filter(PercentTPM, MG == MGName)
PercentTPM <- subset(PercentTPM, duplicated(ClusterRep_MG) | duplicated(ClusterRep_MG, fromLast=TRUE))

# Merge and set NA to Unbinned:
MAGPercent <- merge(MergedMAG, PercentTPM, by.x = "MG_GeneID", by.y = "MG_GeneID", all.x = FALSE, all.y = TRUE)
MAGPercent$Bin <- as.character(MAGPercent$Bin)
MAGPercent$Bin[is.na.data.frame(MAGPercent$Bin)] <- "Unbinned"

# Calculate % of Binned and Unbinned for GF:
MAGPercent2 <- aggregate(x = MAGPercent$Percent, by = list(MAGPercent$ClusterRep_MG, MAGPercent$MG.y, MAGPercent$Bin), FUN = sum)
MAGPercent2 <- data.frame(ClusterRep_MG = MAGPercent2$Group.1, MG_Bin = paste(MAGPercent2$Group.2, MAGPercent2$Group.3, sep = "_"), PercentTPM = MAGPercent2$x)

# Wide DF Format:
WideMAGPercent <- spread(MAGPercent2, ClusterRep_MG, PercentTPM)

# Write Tables:
write.table(MAGPercent2, file = paste(Output, 'MAGPercent2.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)
write.table(WideMAGPercent, file = paste(Output, 'WideMAGPercent.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)

### Extra Script ###
write.table(MergedMAG, file = paste(Output, 'MergedMAG.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)