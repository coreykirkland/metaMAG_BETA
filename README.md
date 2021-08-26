# **MetaMAG**
We should eventually provide a longer introduction describing what the tool is for (text from the paper can be used here) and a diagram describing the tool would be nice too would be nice too.
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
* Metagenome (MG) directories (must be one word - e.g. AcS1)
##### MG Directory containing:
* Assembly File - saved as "final_assembly.fasta"
* BAM File - ending in ".bam"
* PATH to "Binning" Directory

Recommendation: Create a symbolic link to the required input files and directories to avoid moving files and save space.

##### KO Requirements:
* Use representative cluster sequences (fasta file created from MMseqs2) to functionally annotate gene families (GFs) using Kofam_Scan.
* Kofam_Scan output required to calculate KO total TPM and KO percentages in "MetaMAG Script 2" and to integrate this data with MAGs in "MetaMAG Script 3".

## **MetaMAG Modules:**

##### Database creation module:
Add text describing that for now we suggest the method described here e.g. Prodigal, HTSeq-Count, but other methods can be substituted as long as it end up with the same output format - which we will show here.
* Annotates metagenome assembly - Prodigal.
* Alignment statistics and removes duplicates reads - Picard.
* Identifies gene regions - HTSeq-Count.
* Normalises gene reads by Transcripts Per Million (TPM)
Usage: Corey, this would be the actual command the user would type into the terminal
> create_metaMAG_databases input_A input_B etc (threads option?)
Outputs:
> show a head -n5 of each of the output files that is produced here as input for later modules.

##### MetaMAG Script 2 (name rather than number):
* Clusters amino acid sequences from all MGs into gene families (GFs) / clusters - MMseqs2. (maybe move this and the ko annotation to the database creation module). These are all quite modular up to this point, right? e.g. if I wanted to I could do the clustering with something else or annotate with something else)
* MMseqs2 statistics.
* Calculates the number of genes in each GF.
* Calculates TPM for each annotated gene, the total TPM of the genes in a GF/Cluster for a given MG, and the percentage of a genes TPM out of the total TPM for a GF in a given MG.
* Now integrates KO and calculates total TPM and percentages as above for each KO in a MG. SEE KO REQUIREMENTS.

##### MetaMAG Script 3 (name rather than number):
* Calculates the percentage of reads for a GF and for a KO (based on TPM values from "MetaMAG Script 2") that belong to a MAG in each MG. 
* Reads which are not assigned to a MAG are referred to as "Unbinned" for each GF in each MG and the percentage of these is calculated.

##### MetaMAG Script 4:
Deprecated.

##### MetaMAG Script 5:
* Calculates strain-level population statistics (SNV, nucleotide diversity, and pNpS) for genes and averages for GFs.
* Also includes script to combine gene statistics with MAGs.


## **Additional Scripts:**
* No longer required??
* A Bash and R script to merge GF percentages with KO (Kegg Orthology) database assignment for functional annotation of the GFs. Requires output file from KofamScan.
