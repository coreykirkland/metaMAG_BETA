#!/bin/R

# GenomeVisualisation2.R

# commmandArgs:
Args = commandArgs(TRUE)
MergedKOAll <- Args[1]
MergedGF <- Args[2]
MergedKO <- Args[3]
BarchartKO <- Args[4]
BarchartFill <- Args[5]
HeatmapTaxon <- Args[6]
HeatmapValue <- Args[7]
Output <- Args[8]

# Load Libraries:
library(tidyr)
library(dplyr)
library(ggplot2)
library(ComplexHeatmap)
library(circlize)

## Visualisation of Data:

# Barchart - MergedKOAll: 
BarchartKO <- data.frame(BarchartKO)
BarchartDF <- filter(MergedKOAll, KO %in% BarchartKO$BarchartKO)
write.table(BarchartDF, file = paste(Output, 'BarchartKO.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)

pdf(file = paste(Output, 'BarchartKO.pdf', sep = ""), paper = "a4")
ggplot(BarchartDF, aes(fill = get(BarchartFill), y=KOPercent, x=MG)) + geom_bar(position='stack', stat='identity', colour = "white", ) + xlab("Metagenome") + ylab("%") + theme(axis.text.x = element_text(angle = 90))
dev.off() 

# Heatmap - MergedGF:
HeatmapTaxon <- data.frame(HeatmapTaxon)
MergedGF1 <- filter(MergedGF, Order %in% HeatmapTaxon$HeatmapTaxon)
MergedGF1 <- na.omit(MergedGF1)

FilteredGFs <- filter(MergedGF1, MergedGF1$GFPercent > HeatmapValue)
FilteredGFs <- data.frame(GF = FilteredGFs$GF)
MergedGF1 <- merge(MergedGF1, FilteredGFs, by = "GF", all = FALSE)
MergedGF1 <- data.frame(MergedGF1, Pathway_Fun_KO_GF = paste(MergedGF1$Pathway.Name, MergedGF1$Function, MergedGF1$KO, MergedGF1$GF, sep = "_"))
MergedGF1 <- unique(MergedGF1)

MergedGF2 <- data.frame(Pathway_Fun_KO_GF = MergedGF1$Pathway_Fun_KO_GF, Family_Genus_MAG = paste(MergedGF1$Family, MergedGF1$Genus, MergedGF1$MAG, sep = "_"), GFPercent = MergedGF1$GFPercent)
MergedGF2 <- unique(MergedGF2)
MergedGF2 <- spread(MergedGF2, Pathway_Fun_KO_GF, GFPercent)
MergedGF2[is.na(MergedGF2)] <- 0
MergedGF2 <- data.frame(MergedGF2, row.names = 1)
write.table(MergedGF2, file = paste(Output, 'HeatmapGF.tsv', sep = ""), sep = "\t", quote = FALSE, col.names = TRUE, row.names = FALSE)
MatGF <- as.matrix(MergedGF2)

KOInt <- data.frame(Pathway_Fun_KO_GF = MergedGF1$Pathway_Fun_KO_GF, Pathway_Function_KO = paste(MergedGF1$Pathway.Name, MergedGF1$Function, MergedGF1$KO, MergedGF1$KO_Title, sep = "_"), KO_Title = MergedGF1$KO_Title, Pathway = MergedGF1$Pathway.Name, Gene = MergedGF1$Gene)
KOInt <- unique(KOInt)
KOInt <- KOInt[order(KOInt$Pathway_Fun_KO_GF),]
KOInt <- data.frame(KOInt, Pathway_Gene = paste(KOInt$Pathway, KOInt$Gene, sep = "; "), row.names = 1)

Family_Genus <- data.frame(Family_Genus_MAG = paste(MergedGF1$Family, MergedGF1$Genus, MergedGF1$MAG, sep = "_"), MG = MergedGF1$MG, Depth = MergedGF1$Depth, Family_Genus = paste(MergedGF1$Family, MergedGF1$Genus, sep = " "))
Family_Genus <- unique(Family_Genus)
Family_Genus <- Family_Genus[order(Family_Genus$Family_Genus_MAG),]
Family_Genus <- data.frame(Family_Genus, row.names = 1)

col_fun <- colorRamp2(c(0,1,100), c("grey96", "white", "red"))

htGF = Heatmap(MatGF, col = col_fun, name = "%", border = FALSE, cluster_rows = FALSE, cluster_columns = FALSE, show_column_names = FALSE, show_row_names = FALSE, row_split = Family_Genus[,3], column_split = KOInt[,5], row_title_rot = 0, column_title_rot = 90, column_title_gp = gpar(fontsize = 8), row_title_gp = gpar(fontsize = 8), row_order = sort(rownames(MatGF)), column_order = sort(colnames(MatGF)))

pdf(file = paste(Output, 'HeatmapGF.pdf', sep = ""), width = 12, height = 10, paper = "a4r")
draw(htGF, padding = unit(c(0.5,0.5,2,0.5), "cm"))
dev.off()

# Heatmap - MergedKO:
MergedKO1 <- filter(MergedKO, Order %in% HeatmapTaxon$HeatmapTaxon)
MergedKO1 <- na.omit(MergedKO1)

FilteredKOs <- filter(MergedKO1, MergedKO1$KOPercent > HeatmapValue)
FilteredKOs <- data.frame(KO = FilteredKOs$KO)
MergedKO1 <- merge(MergedKO1, FilteredKOs, by = "KO", all = FALSE)
MergedKO1 <- data.frame(MergedKO1, Pathway_Fun_KO = paste(MergedKO1$Pathway.Name, MergedKO1$Function, MergedKO1$KO, sep = "_"))
MergedKO1 <- unique(MergedKO1)

MergedKO2 <- data.frame(Pathway_Fun_KO = MergedKO1$Pathway_Fun_KO, Family_Genus_MAG = paste(MergedKO1$Family, MergedKO1$Genus, MergedKO1$MAG, sep = "_"), KOPercent = MergedKO1$KOPercent)
MergedKO2 <- unique(MergedKO2)
MergedKO2 <- spread(MergedKO2, Pathway_Fun_KO, KOPercent)
MergedKO2[is.na(MergedKO2)] <- 0
MergedKO2 <- data.frame(MergedKO2, row.names = 1)
write.table(MergedKO2, file = paste(Output, 'HeatmapKO.tsv', sep = ""), sep = "\t", quote = FALSE, col.names = TRUE, row.names = FALSE)
MatKO <- as.matrix(MergedKO2)

KOInt_KO <- data.frame(Pathway_Fun_KO = MergedKO1$Pathway_Fun_KO, Pathway_Function_KO = paste(MergedKO1$Pathway.Name, MergedKO1$Function, MergedKO1$KO, MergedKO1$KO_Title, sep = "_"), KO_Title = MergedKO1$KO_Title, Pathway = MergedKO1$Pathway.Name, Gene = MergedKO1$Gene)
KOInt_KO <- unique(KOInt_KO)
KOInt_KO <- KOInt_KO[order(KOInt_KO$Pathway_Fun_KO),]
KOInt_KO <- data.frame(KOInt_KO, Pathway_Gene = paste(KOInt_KO$Pathway, KOInt_KO$Gene, sep = "; "), row.names = 1)

Family_Genus_KO <- data.frame(Family_Genus_MAG = paste(MergedKO1$Family, MergedKO1$Genus, MergedKO1$MAG, sep = "_"), MG = MergedKO1$MG, Depth = MergedKO1$Depth, Family_Genus = paste(MergedKO1$Family, MergedKO1$Genus, sep = " "))
Family_Genus_KO <- unique(Family_Genus_KO)
Family_Genus_KO <- Family_Genus_KO[order(Family_Genus_KO$Family_Genus_MAG),]
Family_Genus_KO <- data.frame(Family_Genus_KO, row.names = 1)

col_fun <- colorRamp2(c(0,1,100), c("grey96", "white", "red"))

htKO = Heatmap(MatKO, col = col_fun, name = "%", border = FALSE, cluster_rows = FALSE, cluster_columns = FALSE, show_column_names = FALSE, show_row_names = FALSE, row_split = Family_Genus_KO[,3], column_split = KOInt_KO[,5], row_title_rot = 0, column_title_rot = 90, column_title_gp = gpar(fontsize = 8), row_title_gp = gpar(fontsize = 8), row_order = sort(rownames(MatKO)), column_order = sort(colnames(MatKO)))

pdf(file = paste(Output, 'HeatmapKO.pdf', sep = ""), width = 12, height = 10, paper = "a4r")
draw(htKO, padding = unit(c(0.5,0.5,2,0.5), "cm"))
dev.off()
