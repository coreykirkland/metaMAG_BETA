#!/bin/R

# GenomeVisualisationBarchart.R

# commmandArgs:
Args = commandArgs(TRUE)
MergedKOAll <- Args[1]
BarchartKO <- Args[2]
BarchartFill <- Args[3]
Output <- Args[4]

# Load Libraries:
library(tidyr)
library(dplyr)
library(ggplot2)

## Visualisation of Data:

# Barchart - MergedKOAll: 
BarchartKO <- data.frame(BarchartKO)
BarchartDF <- filter(MergedKOAll, KO %in% BarchartKO$BarchartKO)
write.table(BarchartDF, file = paste(Output, 'BarchartKO.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)

pdf(file = paste(Output, 'BarchartKO.pdf', sep = ""), paper = "a4")
ggplot(BarchartDF, aes(fill = get(BarchartFill), y=KOPercent, x=MG)) + geom_bar(position='stack', stat='identity', colour = "white", ) + xlab("Metagenome") + ylab("%") + theme(axis.text.x = element_text(angle = 90))
dev.off() 