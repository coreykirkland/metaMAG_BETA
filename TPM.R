#!/bin/R Rscript

# title: "TPM.R" Updated: 09/09/21

# commmandArgs:
Args = commandArgs(TRUE)
TPM <- Args[1]
Cluster <- Args[2]
KO <- Args[3]
Output <- Args[4]

# Load libraries:
library(tidyr)
library(dplyr)

# Read Cluster and TPM files:
Cluster <- read.delim(Cluster, header = FALSE, col.names = c("Cluster_Rep", "Cluster_Member"),  sep = "\t")
TPM <- read.delim(TPM, header = TRUE, col.names = c("Gene_ID", "TPM", "MG"),  sep = "\t")

# Modify Cluster file:
Cluster <- Cluster %>% 
  separate(Cluster_Member, remove = FALSE, c("MG2", "k2","Contig2.1", "Contig2.2", "GeneID2", "GeneID2.1", "GeneID2.2")) %>%
  transform(MG_GeneID=paste(MG2, GeneID2.1, GeneID2.2, sep="_"))
Cluster <- data.frame(MG = Cluster$MG2, Cluster_Rep = Cluster$Cluster_Rep, Cluster_Member = Cluster$Cluster_Member, MG_GeneID = Cluster$MG_GeneID)

# Calculate number of genes (or cluster members) in each GF (cluster representative):
ClusterCount <- data.frame(table(Cluster$Cluster_Rep))
write.table(ClusterCount, file = paste(Output, 'ClusterCount.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = FALSE, row.names = FALSE)

# Modify TPM table:
TPM <- data.frame(MG_GeneID = paste(TPM$MG, TPM$Gene_ID, sep="_"), TPM = TPM$TPM)

# Merged Cluster and TPM files by "MG_GeneID":
ClusterTPM <- merge(Cluster, TPM, by.x = "MG_GeneID", by.y = "MG_GeneID", all.x = FALSE, all.y = FALSE)
ClusterTPM <- unique(ClusterTPM)

## GeneTPM:
GeneTPM <- transform(ClusterTPM, TPM = as.numeric(as.character(ClusterTPM$TPM)))
colnames(GeneTPM) <- c("MG_GeneID", "MG", "GF", "GF_Member", "TPM")
write.table(GeneTPM, file = paste(Output, 'GeneTPM.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)

## TotalTPM:
TotalTPM <- aggregate(x = GeneTPM$TPM, by = list(GeneTPM$GF, GeneTPM$MG), FUN = sum)
colnames(TotalTPM) <- c("GF", "MG", "TotalTPM")
write.table(TotalTPM, file = paste(Output, 'TotalTPM.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)

## PercentTPM:

# Modify TotalTPM and GeneTPM files:
TotalTPM1 <- transform(TotalTPM, GF_MG=paste(GF, MG, sep="_"))
GeneTPM1 <- transform(GeneTPM, GF_MG=paste(GF, MG, sep="_"))

# Merge GeneTPM and TotalTPM by "GF_MG":
MergedDF <- merge(GeneTPM1, TotalTPM1, by.x = "GF_MG", by.y = "GF_MG", all.x = FALSE, all.y = FALSE)
MergedDF <- unique(MergedDF)

# Calculate percentages for GFs:
PercentTPM <- transform(MergedDF, Percent_GF = (MergedDF$TPM / MergedDF$TotalTPM)*100)
PercentTPM <- na.omit(PercentTPM) # Removes any NA values due to a total TPM of 0
PercentTPM <- data.frame(MG = PercentTPM$MG.x, GF = PercentTPM$GF.x, GF_Member = PercentTPM$GF_Member, MG_GeneID = PercentTPM$MG_GeneID, TPM = PercentTPM$TPM, TotalTPM = PercentTPM$TotalTPM, Percent_GF = PercentTPM$Percent_GF)

# Read KO file from Kofam Scan:
KO <- read.delim(KO, header = FALSE, sep = "\t", col.names = c("GF", "KO"))

# Merge PercentTPM and KO:
MergedDF <- merge(PercentTPM, KO, by = "GF", all.x = TRUE, all.y = FALSE)
MergedDF <- unique(MergedDF)
MergedDF <- na.omit(MergedDF)
MergedDF <- data.frame(MergedDF, MG_KO = paste(MergedDF$MG, MergedDF$KO, sep = "_"))

# Sum TPM for each MG_KO (KO in each MG):
PercentKO <- aggregate(MergedDF$TPM, by = list(MergedDF$MG_KO), FUN = sum)
PercentKO <- data.frame(MG_KO = PercentKO$Group.1, TotalTPM_KO = PercentKO$x)

# Merge to form one table:
PercentTPM2 <- merge(MergedDF, PercentKO, by = "MG_KO", all.x = TRUE, all.y = FALSE)
PercentTPM2 <- unique(PercentTPM2)

# Calculate percentage for KO:
PercentTPM3 <- transform(PercentTPM2, Percent_KO = (PercentTPM2$TPM / PercentTPM2$TotalTPM_KO)*100)
PercentTPM3 <- na.omit(PercentTPM3)

# Write PercentTPM file:
write.table(PercentTPM3, file = paste(Output, 'PercentTPM.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)