#!/bin/R Rscript

# title: "MetaMAG SNV" Updated: 17/6/21

# commandArgs:

Args = commandArgs(TRUE)
GeneSNVs <- Args[1]
Clustering <- Args[2]
MergedMAG <- Args[3]
Output <- Args[4]

# Load Library:
library(dplyr)
library(tidyr)

# Read TSV Files:

GeneSNVs <- read.delim(GeneSNVs, header = TRUE, sep = "\t")
Clustering <- read.delim(Clustering, header = FALSE, col.names = c("Cluster_Rep", "Cluster_Member"), sep = "\t")

# Modify GeneSNVs:

GeneSNVs <- separate(GeneSNVs, gene, c("contig", "contig1", "length", "length1", "cov", "cov1", "gene"), sep = "_")
GeneSNVs <- data.frame(scaffold = GeneSNVs$scaffold, MG_gene = paste(GeneSNVs$MG, GeneSNVs$contig, GeneSNVs$contig1, GeneSNVs$gene, sep = "_"), nucl_diversity = GeneSNVs$nucl_diversity, pNpS_variants = GeneSNVs$pNpS_variants, SNV_count = GeneSNVs$SNV_count, SNV_S_count = GeneSNVs$SNV_S_count, SNV_N_count = GeneSNVs$SNV_N_count)

# Merge TSV Files: Based on Gene and Cluster Member

MergedDf <- merge(GeneSNVs, Clustering, by.x = "MG_gene", by.y = "Cluster_Member", all = FALSE)
MergedDfNaOmit <- na.omit(MergedDf)

write.table(MergedDfNaOmit, file = paste(Output, 'MergedDfNaOmit.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)

# Gene Family Statistics - SNVs:

MeanSNV <- aggregate(x = MergedDfNaOmit$SNV_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
colnames(MeanSNV) <- c("GF", "MeanSNV")
TotalSNV <- aggregate(x = MergedDfNaOmit$SNV_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sum)
colnames(TotalSNV) <- c("GF", "TotalSNV")
MergedSNV <- merge(MeanSNV, TotalSNV, by.x = "GF", by.y = "GF")

MeanSNVS <- aggregate(x = MergedDfNaOmit$SNV_S_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
colnames(MeanSNVS) <- c("GF", "MeanSNVS")
TotalSNVS <- aggregate(x = MergedDfNaOmit$SNV_S_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sum)
colnames(TotalSNVS) <- c("GF", "TotalSNVS")
MergedSNVS <- merge(MeanSNVS, TotalSNVS, by.x = "GF", by.y = "GF")

MeanSNVN <- aggregate(x = MergedDfNaOmit$SNV_N_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
colnames(MeanSNVN) <- c("GF", "MeanSNVN")
TotalSNVN <- aggregate(x = MergedDfNaOmit$SNV_N_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sum)
colnames(TotalSNVN) <- c("GF", "TotalSNVN")
MergedSNVN <- merge(MeanSNVN, TotalSNVN, by.x = "GF", by.y = "GF")

SNVData <- merge(MergedSNV, MergedSNVS, by.x = "GF", by.y = "GF")
SNVData <- merge(SNVData, MergedSNVN, by.x = "GF", by.y = "GF")

# Gene Family Statistics - Nucleotide Diversity:

MeanNucDiv <- aggregate(x = MergedDfNaOmit$nucl_diversity, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
SDNucDiv <- aggregate(x = MergedDfNaOmit$nucl_diversity, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sd)
NucDivMerge <- merge(MeanNucDiv, SDNucDiv, by.x = "Group.1", by.y = "Group.1", all = FALSE)
colnames(NucDivMerge) <- c("GF", "Mean_NucDiv", "SD_NucDiv")

# Gene Family Statistics - pN/pS:

MeanpNpS <- aggregate(x = MergedDfNaOmit$pNpS_variants, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
SDpNpS <- aggregate(x = MergedDfNaOmit$pNpS_variants, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sd)
pNpSMerge <- merge(MeanpNpS, SDpNpS, by.x = "Group.1", by.y = "Group.1", all = FALSE)
colnames(pNpSMerge) <- c("GF", "Mean_pNpS", "SD_pNpS")

# Write Data Frames:

write.table(SNVData, file = paste(Output, 'SNVs.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
write.table(NucDivMerge, file = paste(Output, 'NucDiv.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
write.table(pNpSMerge, file = paste(Output, 'pNpS.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)

### Extra Script ###

# Integrate MAGs:
MergedMAG <- read.delim(MergedMAG, header = TRUE, sep = "\t")
MergedMAG <- separate(MergedMAG, GeneID, c("ID", "gene"), sep = "_")
MergedMAG <- data.frame(Bin = MergedMAG$Bin, MG_gene = paste(MergedMAG$MG, MergedMAG$Contig, MergedMAG$gene, sep = "_"))

MergedBin <- merge(MergedDfNaOmit, MergedMAG, by.x = "MG_gene", by.y = "MG_gene", all = FALSE)

write.table(MergedBin, file = paste(Output, 'GeneSNV_MAG.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
