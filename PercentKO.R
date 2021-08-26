#!/bin/R Rscript

# title: "PercentKO"

# commmandArgs:
Args = commandArgs(TRUE)
PercentTPM <- Args[1]
KO <- Args[2]
Output <- Args[3]

# Load Library:
library(tidyr)
library(dplyr)

PercentTPM <- read.delim(PercentTPM, sep = "\t", header = TRUE)

KO <- read.delim(KO, header = FALSE, sep = "\t", col.names = c("Contig", "GeneID", "KO"))
# Paste columns 1 and 2 back together:
KO <- data.frame(ClusterRep = paste(KO$Contig, KO$GeneID, sep = "_"), KO = KO$KO)

# Remove MG from ClusterRep_MG
PercentTPM1 <- separate(PercentTPM, ClusterRep_MG, into=c("a","b","c","d","e","f","g"), sep = "_")
PercentTPM1 <- data.frame(MG = PercentTPM1$MG, ClusterRep = paste(PercentTPM1$a, PercentTPM1$b, PercentTPM1$c, PercentTPM1$d, PercentTPM1$e, PercentTPM1$f, sep = "_"), ClusterRepMG = PercentTPM1$g, Cluster_Member = PercentTPM1$Cluster_Member, MG_GeneID = PercentTPM1$MG_GeneID, TPM = PercentTPM1$TPM, TotalTPM = PercentTPM1$TotalTPM, GFPercent = PercentTPM1$Percent)

# Merge PercentTPM and KO:
MergedDF <- merge(PercentTPM1, KO, by = "ClusterRep", all = TRUE)
MergedDF <- unique(MergedDF)
MergedDF1 <- na.omit(MergedDF)
MergedDF1 <- data.frame(MergedDF1, MG_KO = paste(MergedDF1$MG, MergedDF1$KO, sep = "_"))

# Aggregate TPM for MG and KO:
PercentKO <- aggregate(MergedDF1$TPM, by = list(MergedDF1$KO, MergedDF1$MG), FUN = sum)
PercentKO <- data.frame(MG_KO = paste(PercentKO$Group.2, PercentKO$Group.1, sep = "_"), KOTotalTPM = PercentKO$x)

# Merge PercentKO and PercentTPM:
PercentTPM2 <- merge(MergedDF1, PercentKO, by = "MG_KO", all = TRUE)
PercentTPM2 <- unique(PercentTPM2)

# Calculate percentages for KO:
PercentTPM3 <- transform(PercentTPM2, KOPercent = (PercentTPM2$TPM / PercentTPM2$KOTotalTPM)*100)
PercentTPM3 <- na.omit(PercentTPM3) # Removes any NA values due to a total TPM of 0

# Write table:
write.table(PercentTPM3, file = paste(Output, 'PercentTPM_Updated.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)