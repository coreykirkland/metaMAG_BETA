#!/bin/R Rscript

# title: "Mmseqs2 Stats" Updated: 8/4/21

# commandArgs:

Args = commandArgs(TRUE)
AllCluster <- Args[1]
Output <- Args[2]

# Load Libraries:

library(tidyr)
library(dplyr)
library(ggplot2)

# 	Read cluster file:
AllCluster <- read.delim(AllCluster, sep = "\t", header = FALSE)

# Calculate no. genes in each GF:
AllCluster1 <- AllCluster %>%
  group_by(V1) %>%
  summarise(No.Genes = n())

NumberCluster <- AllCluster1 %>%
  group_by(No.Genes) %>%
  summarise(No.GFs = n())

# Print histogram of the frequency of genes in GFs:
options(scipen=100000)

pdf(file = paste(Output, 'MmseqsHistogram.pdf', sep = ""), paper = "a4")
ggplot(NumberCluster, aes(x = No.Genes, y = No.GFs)) + geom_bar(stat = "identity", colour = "steelblue") + theme_bw() + scale_y_log10() + ylab("Log No.GFs")
dev.off() 

# Calculate percentage of singleton and multi-gene GFs:
MmseqsStats <- data.frame(Singletons = sum(AllCluster1$No.Genes==1), MultiGene_GF = sum(AllCluster1$No.Genes>1), Total = nrow(AllCluster1))
MmseqsStats <- data.frame(Singletons = MmseqsStats$Singletons, Percent_Singletons = ((MmseqsStats$Singletons / MmseqsStats$Total) * 100), MultiGene_GF = MmseqsStats$MultiGene_GF, Percent_MultiGene_GF = ((MmseqsStats$MultiGene_GF / MmseqsStats$Total) * 100), Total = MmseqsStats$Total)

write.table(MmseqsStats, file = paste(Output, 'MmseqsStats.tsv', sep = ""), sep = "\t", row.names = FALSE)