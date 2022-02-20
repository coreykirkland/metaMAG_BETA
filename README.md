# **metaMAG**
#### Integrating Three Levels of Metagenomic Information: 
#### 1) Gene-centric
#### 2) Genome-centric
#### 3) Strain-centric


## **Dependencies:**
* Prodigal v2.6.3
* Picard v2.25.0
* HTSeq v0.13.5
* Python v3.7.3 and Pandas v0.24.2
* MMseqs2 v13.45111
* inStrain v1.5.3
## **Dependencies: R**
* R v4.0.2
* R Packages: tidyr, dplyr, ggplot2


## **Required Input Files:**
* Contig file (.fasta) for each metagenome (MG).
* Alignment/mapping file (.bam) for each MG.
* Name of directory containing all bin files (.fasta) for each MG.



## **MetaMAG Modules:**

#### Modules:
![Modules_1](https://github.com/coreykirkland/metaMAG_test/blob/e9061dbffec80597f34860dab92594fa9b759654/metaMAG.drawio(2).svg)  

#### Pipeline:
![pipeline_1](https://github.com/coreykirkland/metaMAG_test/blob/33e65ee534199bd91a69a94bc4d89b915a0b2cae/metaMAG.drawio(1).svg)  



## 1. metaMAG_setup module:
* Calls genes in metagenome assembly - Prodigal.
* Calculates alignment statistics and removes duplicate reads - Picard.
* Counts the number of reads aligned to each gene - HTSeq-Count.
* Normalises gene reads by Transcripts Per Million (TPM) - https://github.com/EnvGen/metagenomics-workshop

##### Usage:
```
sh metaMAG_setup.sh -m <Metagenome Name> -c <Contigs File> -a <Alignment File> -j <PATH to Java> -o <Output Directory>
```
metaMAG Module: metaMAG_setup.sh  
-m: Metagenome name (must be one word with no spaces or special characters, e.g. MG1)  
-c: Contigs file from assembly step (.fa or .fasta)  
-a Alignment/mapping file (.bam)  
-j PATH to Java (required to Picard).  
-o: Output directory (this is where a folder called “metaMAG” will be created and contain all output files for all modules).  
Note: All arguments required to successfully run the module.  

##### Outputs:



## 2. metaMAG_cluster module:
* Clusters amino acid sequences from all MGs into protein families - MMseqs2.
* Calculates MMseqs2 statistics - R script.

##### Usage:
```
sh metaMAG_cluster.sh -m <Metagenome Name> -t <No. of Threads> -o <Output Directory>
```
metaMAG Module: metaMAG_cluster.sh  
-m: Metagenome name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).  
-t: Number of threads for MMseqs2 program.  
-o: Output directory (must be the same as used in previous module).  
Note: All arguments required to successfully run the module.  

##### Outputs:



## 3. metaMAG_kofam module:
* Functionally annotates the representative protein family sequences from the MMseqs2 output - Kofam Scan.

##### Usage:
```
sh metaMAG_kofam.sh -k <KO List> -p <Profile> -t <No. of Threads> -o <Output Directory>
```
metaMAG module: metaMAG_kofam.sh  
-k: KO list (required for Kofam Scan - see https://github.com/takaram/kofam_scan)  
-p: Profile (required for Kofam Scan - see https://github.com/takaram/kofam_scan)  
-t: Number of threads.  
-o: Output directory (must be the same as used in previous module).  

##### Output:
(Highlight the Kofam output file required for next module).



## 4. metaMAG_gene module:
* Integrates gene family (GF) and KEGG Orthology (KO) with TPM data - R script (TPM.R).

##### Usage:
```
sh metaMAG_gene.sh -m <Metagenome Name> -k <Kofam Output> -o <Output Directory>
```
metaMAG module: metaMAG_gene.sh  
-m: Metagenome name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).  
-k: Kofam output file (two column file containing name and KO k number)  
-o: Output directory (must be the same as used in previous module).  

##### Output:
(Output files)



## 5. metaMAG_genome module:
* Calculates 

##### Usage:
```
sh metaMAG_genome.sh -m <Metagenome Name> -b <Bin Directory> -o <Output Directory>
```
metaMAG module: metaMAG_genome.sh  
-m: Metagenome Name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).  
-b: Bin directory - PATH to directory containing .fa files from binning step. (More details needed).  
-o: Output directory (must be the same as used in previous module).  

##### Output:
(Output files)



## 6. metaMAG_strain module:
* Calculates population genetic statistics (SNVs, nucleotide diversity, pNpS ratios) - inStrain.
* Calculates... - R script.
* Optional module.

##### Usage:
```
sh metaMAG_strain.sh -m <Metagenome Name> -a <Alignment File> -c <Contigs File> -t <No. of Thread> -o <Output Directory>
```
metaMAG module: metaMAG_strain.sh  
-m: Metagenome Name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).  
-a: Alignment/mapping file (.bam; same as the file used in the metaMAG_setup module).  
-c: Contigs file (.fa/.fasta; same as the file used in the metaMAG_setup module).  
-t: Number of threads required for inStrain.  
-o: Output directory (must be the same as used in previous module).  

##### Output:
(Output files)



## metaMAG Visualisation:  
* Scripts for the analysis and visualisation of data from metaMAG_genome module

## 1. metaMAG_visualisation_setup
* Combines data produced during metaMAG_genome with KEGG information (selected KOs and all KOs) and MAG classification.
* Run this script once to setup files required for below scripts:
* Requires a table of MAG classification

##### Usage:
```
sh metaMAG_visualisation_setup.sh -o <Output Directory>
```
metaMAG module: metaMAG_visualisation_setup.sh
-o: Output directory (must be the same as used in previous modules).

## metaMAG_visualisation_barchart
* Produces a barchart for a given KO (e.g. KO1944) and taxonomy level (e.g. Phylum)

##### Usage:
```
sh metaMAG_visualisation_barchart.sh -k <KEGG K-Number> -b <Taxon Level> -o <Output Directory>
```
metaMAG module: metaMAG_visualisation_barchart.sh
-k: KEGG k-number (e.g. KO1944).
-b: Taxon level - Domain Kingdom Phylum Class Order Family Genus Species
-o: Output directory (must be the same as used in previous modules).

## metaMAG_visualisation_heatmap
* Produces a heatmap for MAGs from a given order using a database of selected KOs. 

##### Usage:
```
sh etaMAG_visualisation_heatmap.sh -t <Order Name> -p <Greater Than Percentage> -o <Output Directory> 
```
metaMAG module: metaMAG_visualisation_heatmap.sh
-t: Name of order based on MAG classification table (e.g. o__Solirubrobacterales)
-p: Include GFs/KOs with at least one MAG greater than "percentage" (e.g. 50)
-o: Output directory (must be the same as used in previous modules).

