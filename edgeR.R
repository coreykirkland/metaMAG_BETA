#!/bin/R Rscript

# title: "edgeR Script: GF Abundance" Updated: 1/4/21

# commandArgs:
Args = commandArgs(TRUE)
TotalTPM <- Args[1]
GroupTable <- Args[2]
Output <- Args[3]

# Load Packages:
library(edgeR)
library(tidyr)

# Read TotalTPM File:
TotalTPM <- read.delim(TotalTPM, header = TRUE, sep = "\t")

# Modify TPM Dataframe and Convert to Matrix:
TotalTPMWide <- spread(TotalTPM, MG, TotalTPM)
TotalTPMWide <- data.frame(TotalTPMWide)
TotalTPMWide[is.na(TotalTPMWide)] <- 0

# Create DGEList:
DGEList <- DGEList(counts=TotalTPMWide[,2:ncol(TotalTPMWide)], genes=TotalTPMWide[,1])

# Design Matrix:
Group <- read.delim(GroupTable, header = TRUE, sep = "\t")
Group <- factor(Group[,2])
design <- model.matrix(~Group)
rownames(design) <- colnames(DGEList)

# Dispersion:
DGEList <- estimateDisp(DGEList, design, robust=TRUE)
DGEList$common.dispersion

# Differential Expression:
fit <- glmFit(DGEList, design) # Fit a negative binomial generalized log-linear model to the read counts for each gene. 
lrt <- glmLRT(fit) 
TopTags <- topTags(lrt, n=100, sort.by = "logFC") # Extracts top 100 most differentially expressed GFs.
colnames(TopTags$table)[colnames(TopTags$table) == "genes"] <- "GF"

# Output:
write.table(TopTags$table, file = paste(Output, 'TopTags.tsv', sep = ""), quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
