#!/bin/R Rscript

# title: "GF_TPM" Updated: 1/4/21

# commmandArgs:
Args = commandArgs(TRUE)
TPM <- Args[1]
Cluster <- Args[2]
Output <- Args[3]

# Load Tidyr:
library(tidyr)

# Read TSV Files:
AllMGCluster <- read.delim(Cluster, header = FALSE, col.names = c("Cluster_Rep", "Cluster_Member"),  sep = "\t")
AllMGTPM <- read.delim(TPM, header = TRUE, col.names = c("Gene_ID", "TPM", "MG"),  sep = "\t")

# Modify Cluster TSV: 
AllMGCluster <- AllMGCluster %>% 
  separate(Cluster_Rep, remove = FALSE, c("MG1", "k1","Contig1.1","Contig1.2", "GeneID1", "GeneID1.1", "GeneID1.2")) %>%
  separate(Cluster_Member, remove = FALSE, c("MG2", "k2","Contig2.1", "Contig2.2", "GeneID2", "GeneID2.1", "GeneID2.2")) %>%
  transform(MG_GeneID=paste(MG2, GeneID2.1, GeneID2.2, sep="_"))

AllMGCluster <- data.frame(MG = AllMGCluster$MG2, Cluster_Rep = AllMGCluster$Cluster_Rep, Cluster_Member = AllMGCluster$Cluster_Member, MG_GeneID = AllMGCluster$MG_GeneID)

# Calculate number of genes in each GF:
ClusterCount <- data.frame(table(AllMGCluster$Cluster_Rep))

# Modify TPM TSV:
AllMGTPM <- transform(AllMGTPM, MG_GeneID=paste(MG, Gene_ID, sep="_"))
AllMGTPM <- data.frame(MG_GeneID = AllMGTPM$MG_GeneID, TPM = AllMGTPM$TPM)

# Merge TSV Files: by MG_GeneID:
AllMGMerged <- merge(AllMGCluster, AllMGTPM, by.x = "MG_GeneID", by.y = "MG_GeneID", all.x = FALSE, all.y = FALSE)
 
# TPM as numeric values and create GeneTPM table:
GeneTPM <- transform(AllMGMerged, TPM=as.numeric(as.character(AllMGMerged$TPM)))

# Calculate TotalTPM and create table:
TotalTPM <- aggregate(x = GeneTPM$TPM, by = list(GeneTPM$Cluster_Rep, GeneTPM$MG), FUN = sum)
colnames(TotalTPM) <- c("Cluster_Rep", "MG", "TotalTPM")

# Modify Data Frames:
TotalTPM1 <- transform(TotalTPM, ClusterRep_MG=paste(Cluster_Rep, MG, sep="_"))
GeneTPM1 <- transform(GeneTPM, ClusterRep_MG=paste(Cluster_Rep, MG, sep="_"))

# Merge Data Frames:
MergedDF <- merge(GeneTPM1, TotalTPM1, by.x = "ClusterRep_MG", by.y = "ClusterRep_MG", all.x = FALSE, all.y = FALSE)

# Calculate (Gene TPM / Total GF TPM) *100 per MG
PercentTPM <- transform(MergedDF, Percent = (MergedDF$TPM / MergedDF$TotalTPM)*100)
PercentTPM <- na.omit(PercentTPM) # Removes any NA values due to a total TPM of 0
PercentTPM <- data.frame(MG = PercentTPM$MG.x, ClusterRep_MG = PercentTPM$ClusterRep_MG, Cluster_Member = PercentTPM$Cluster_Member, MG_GeneID = PercentTPM$MG_GeneID, TPM = PercentTPM$TPM, TotalTPM = PercentTPM$TotalTPM, Percent = PercentTPM$Percent)

# Write Tables:
write.table(TotalTPM, file = paste(Output, 'TotalTPM.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
write.table(GeneTPM, file = paste(Output, 'GeneTPM.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
write.table(ClusterCount, file = paste(Output, 'ClusterCount.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = FALSE, row.names = FALSE)
write.table(PercentTPM, file = paste(Output, 'PercentTPM.tsv', sep = ""), quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)