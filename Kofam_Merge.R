#!/bin/R Rscript

# title: "Kofam Merge" Updated: 2/6/21

# commandArgs:
Args = commandArgs(TRUE)
MAGPercent <- Args[1]
Kofam <- Args[2]
Output <- Args[3]

# Read table from...
MAGPercent <- read.delim(MAGPercent, sep = "\t", header = TRUE, col.names = c("GF", "MAG", "Percent"))
Kofam <- read.delim(Kofam, sep = "\t", header = FALSE, col.names = c("GF", "KO"))

MergedDF <- merge(MAGPercent, Kofam, by.x = "GF", by.y = "GF", all.x = TRUE, all.y = FALSE)

# Write table to...
write.table(MergedDF, file = paste(Output, 'MAGPercent_Kofam.tsv', sep = ""), quote = FALSE, col.names = TRUE, sep = "\t", row.names = FALSE)