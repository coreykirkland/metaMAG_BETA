# **MetaMAG**
### Integrating Three Levels of Metagenomic Analysis: 
### 1) Genome-centric
### 2) Gene-centric
### 3) Strain-centric

### **Dependencies: Conda Environments**
* PRODIGAL v2.6.3
* Picard v2.25.0
* HTSeq v0.13.5
* Pandas v0.24.2 and Python v3.7.3
* MMseqs2 v13.45111
* inStrain v1.5.3
### **Dependencies: R**
* R v4.0.2
* R Packages: tidyr, dplyr, ggplot2

### **INPUT - MetaMAG Directory Structure:**
##### Working directory (where scripts are run) containing:
* MetaMAG Bash Scripts
* R Scripts
* Metagenome (MG) directories (must be one word - i.e. AcS1)
##### MG Directory containing:
* "final_assembly.fasta" File
* .bam File
* "Binning" Directory

Recommendation: Create a symbolic link to the required input files and directories to avoid moving files and save space.

### **MetaMAG Scripts:**
##### MetaMAG Script 1:
* Annotates metagenome assembly using - Prodigal.
* Alignment statistics and removes duplicates reads - Picard.
* Identifies gene regions - HTSeq-Count.
* Normalisation by Transcripts Per Million (TPM)

##### MetaMAG Script 2:
* Clusters amino acid sequences from all MGs into gene families (GFs) - MMseqs2.
* MMseqs2 statistics.
* Calculates TPM for each annotated gene, the total TPM of the genes in a GF/Cluster, and the percentage of a genes TPM within a GF. Also calculates the number of genes in each GF.

