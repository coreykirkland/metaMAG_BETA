# **MetaMAG**
#### Integrating Three Levels of Metagenomic Information: 
#### 1) Genome-centric
#### 2) Gene-centric
#### 3) Strain-centric


## **Dependencies: Conda Environments**
* Prodigal v2.6.3
* Picard v2.25.0
* HTSeq v0.13.5
* Python v3.7.3 and Pandas v0.24.2
* MMseqs2 v13.45111
* inStrain v1.5.3
## **Dependencies: R**
* R v4.0.2
* R Packages: tidyr, dplyr, ggplot2


## **INPUT - MetaMAG Directory Structure:**
##### Working directory (where scripts are run) containing:
* MetaMAG Bash Scripts
* R Scripts
* Metagenome (MG) directories (must be one word - i.e. AcS1)
##### MG Directory containing:
* Assembly File - saved as "final_assembly.fasta"
* BAM File - ending in ".bam"
* PATH to "Binning" Directory

Recommendation: Create a symbolic link to the required input files and directories to avoid moving files and save space.


## **MetaMAG Scripts:**

##### MetaMAG Script 1:
* Annotates metagenome assembly - Prodigal.
* Alignment statistics and removes duplicates reads - Picard.
* Identifies gene regions - HTSeq-Count.
* Normalises gene reads by Transcripts Per Million (TPM)

##### MetaMAG Script 2:
* Clusters amino acid sequences from all MGs into gene families (GFs) / clusters - MMseqs2.
* MMseqs2 statistics.
* Calculates the number of genes in each GF.
* Calculates TPM for each annotated gene, the total TPM of the genes in a GF/Cluster for a given MG, and the percentage of a genes TPM out of the total TPM for a GF in a given MG. 

##### MetaMAG Script 3:
* Calculates the percentage of reads for a GF and for a KO (based on TPM values from "MetaMAG Script 2") in a given MG that belong to a MAG. 
* Reads which are not assigned to a MAG are referred to as "Unbinned" for each GF in each MG and the percentage of these is calculated.

##### MetaMAG Script 4:
Deprecated.

##### MetaMAG Script 5:
* Calculates strain-level population statistics (SNV, nucleotide diversity, and pNpS) for genes and averages for GFs.
* Also includes script to combine gene statistics with MAGs.


## **Additional Scripts:**
* A Bash and R script to merge GFs with KO (Kegg Orthology) database assignment for functional annotation of the GFs. Requires output file from KofamScan.
