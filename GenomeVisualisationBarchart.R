#!/bin/R

# GenomeVisualisationBarchart.R

# commmandArgs:
Args = commandArgs(TRUE)
MergedKOAll <- Args[1]
BarchartKO <- Args[2]
Output <- Args[3]

# Load Libraries:
library(tidyr)
library(dplyr)
library(ggplot2)

## Visualisation of Data:

# Read Data:
MergedKOAll <- read.delim(MergedKOAll, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
#MergedKOAll[is.na(MergedKOAll)] = "Unbinned"

# Barchart - MergedKOAll: 
BarchartKO <- data.frame(BarchartKO)
BarchartDF <- filter(MergedKOAll, KO %in% BarchartKO$BarchartKO)
BarchartDF <- na.omit(BarchartDF)
write.table(BarchartDF, file = paste(Output, 'BarchartKO.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)


##### For another taxonomic level change BarchartDF$Phylum to BarchartDF$Class for example #####
BarchartDF <- data.frame(KO = BarchartDF$KO, MG = BarchartDF$MG, Taxon = BarchartDF$Phylum, KOPercent = BarchartDF$KOPercent) 
#####


pdf(file = paste(Output, 'BarchartKO.pdf', sep = ""), paper = "a4")
ggplot(BarchartDF, aes(fill = Taxon, x = MG)) + geom_bar(colour = "white", size = 0.01) + xlab("Metagenome") + ylab("% of mapped reads") + theme(axis.text.x = element_text(angle = 45, hjust=1, vjust=1)) + labs(fill='Taxon') +scale_y_continuous(limits=c(0,100)) + theme(legend.position="bottom") + guides(fill=guide_legend(ncol=3))
dev.off()
