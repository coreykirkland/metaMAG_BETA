#!/bin/R Rscript

# title: "MetaMAG SNV" Updated: 8/4/21

# commandArgs:

Args = commandArgs(TRUE)
GeneSNVs <- Args[1]
Clustering <- Args[2]
MergedMAG <- Args[3]
Output <- Args[4]

# Read TSV Files:

GeneSNVs <- read.delim(GeneSNVs, header = TRUE, sep = "\t")
Clustering <- read.delim(Clustering, header = FALSE, col.names = c("Cluster_Rep", "Cluster_Member"), sep = "\t")

# Merge TSV Files: Based on Gene and Cluster Member

MergedDf <- merge(GeneSNVs, Clustering, by.x = "gene", by.y = "Cluster_Member", all.x = FALSE, all.y = FALSE)
MergedDfNaOmit <- na.omit(MergedDf)

# Cluster Statistics - SNVs:

MeanSNV <- aggregate(x = MergedDfNaOmit$SNV_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
colnames(MeanSNV) <- c("Cluster", "MeanSNV")
TotalSNV <- aggregate(x = MergedDfNaOmit$SNV_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sum)
colnames(TotalSNV) <- c("Cluster", "TotalSNV")
MergedSNV <- merge(MeanSNV, TotalSNV, by.x = "Cluster", by.y = "Cluster")

MeanSNVS <- aggregate(x = MergedDfNaOmit$SNV_S_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
colnames(MeanSNVS) <- c("Cluster", "MeanSNVS")
TotalSNVS <- aggregate(x = MergedDfNaOmit$SNV_S_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sum)
colnames(TotalSNVS) <- c("Cluster", "TotalSNVS")
MergedSNVS <- merge(MeanSNVS, TotalSNVS, by.x = "Cluster", by.y = "Cluster")

MeanSNVN <- aggregate(x = MergedDfNaOmit$SNV_N_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
colnames(MeanSNVN) <- c("Cluster", "MeanSNVN")
TotalSNVN <- aggregate(x = MergedDfNaOmit$SNV_N_count, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sum)
colnames(TotalSNVN) <- c("Cluster", "TotalSNVN")
MergedSNVN <- merge(MeanSNVN, TotalSNVN, by.x = "Cluster", by.y = "Cluster")

SNVData <- merge(MergedSNV, MergedSNVS, by.x = "Cluster", by.y = "Cluster")
SNVData <- merge(SNVData, MergedSNVN, by.x = "Cluster", by.y = "Cluster")

# Cluster Statistics - Nucleotide Diversity:

MeanNucDiv <- aggregate(x = MergedDfNaOmit$nucl_diversity, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
SDNucDiv <- aggregate(x = MergedDfNaOmit$nucl_diversity, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sd)
NucDivMerge <- merge(MeanNucDiv, SDNucDiv, by.x = "Group.1", by.y = "Group.1", all = FALSE)
colnames(NucDivMerge) <- c("Cluster", "Mean_NucDiv", "SD_NucDiv")

# Cluster Statistics - pN/pS:

MeanpNpS <- aggregate(x = MergedDfNaOmit$pNpS_variants, by = list(MergedDfNaOmit$Cluster_Rep), FUN = mean)
SDpNpS <- aggregate(x = MergedDfNaOmit$pNpS_variants, by = list(MergedDfNaOmit$Cluster_Rep), FUN = sd)
pNpSMerge <- merge(MeanpNpS, SDpNpS, by.x = "Group.1", by.y = "Group.1", all = FALSE)
colnames(pNpSMerge) <- c("Cluster", "Mean_pNpS", "SD_pNpS")

# Write Data Frames:

write.table(SNVData, file = paste(Output, 'SNVs.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
write.table(NucDivMerge, file = paste(Output, 'NucDiv.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
write.table(pNpSMerge, file = paste(Output, 'pNpS.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)

### Extra Script ###

# Integrate MAGs:
MergedMAG <- read.delim(MergedMAG, header = TRUE, sep = "\t")
MergedMAG <- data.frame(MergedMAG, k_GeneID = paste(MergedMAG$k, MergedMAG$GeneID, sep = "_"))
MergedBin <- merge(MergedDfNaOmit, MergedMAG, by.x = "gene", by.y = "k_GeneID", all = FALSE)
write.table(MergedMAG, file = paste(Output, 'GeneInfo_MAG', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
