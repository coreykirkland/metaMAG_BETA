# **metaMAG**
### Integrating Metagenome (meta) and Metagenome-Assembled Genome (MAG) Data


## **Dependencies:**
* Prodigal v2.6.3
* Picard v2.25.0
* HTSeq v0.13.5
* Python v3.7.3 and Pandas v0.24.2
* MMseqs2 v13.45111
* Kofam_Scan v1.3.0 (requires database - ftp.genome.jp/pub/db/kofam/)
* inStrain v1.5.3  
* R v4.0.2
* R Packages: tidyr, dplyr, ggplot2, ComplexHeatmap, circlize  
Note: these versions have been tested   

**Conda:** YAML files have been created for each module/script - see Conda folder

## **Required Input Files:**
**1. Contig file (.fasta) for a metagenome (MG)**
```
>NODE_1_length_1221932_cov_20.113987
GCTGATGAAGGCGCTCGCGAGCGAGCTCGGCGTCGAGATGATCTCGATCAAGTGCAGCGA
TCTGATGAGCAAGTGGTACGGCGAGTCGGAGAACCGCGTCGCCGACCTTCTGCGCACCGC
CCGAGAGCGGGCCCCGTGCATCCTGTTCATGGACGAGATCGACGCGGTGGCCAAGCGCCG
CGACATGTACACCGCGGACGATGTCACGCCCCGGCTGCTGAGCATCCTGCTCAGCGAGAT
```
**2. Alignment/mapping file (.bam) for a MG**

**3. Name of directory containing all bin files (.fasta) for a MG**  

Example of directory:
```
AcS5-100.fa  AcS5-118.fa  AcS5-16.fa  AcS5-34.fa  AcS5-51.fa  AcS5-69.fa  AcS5-86.fa
AcS5-101.fa  AcS5-119.fa  AcS5-17.fa  AcS5-35.fa  AcS5-52.fa  AcS5-6.fa   AcS5-87.fa
```
Example of Fasta:
```
>NODE_2_length_707815_cov_20.038156
TTGGTATCCACTTTCTGAAGCGGATGCGAATTGCCGAGAGGTTCAGGGGCCGACGGCCGC
AGGAGCCGTCGGCCCCCGTCTCCCCGGAGCAGTTCAGGAGAGATGGTTTTCTTTCCAAGC
CTTTGATACAATGGAGCCAATGGCAACCAGGAAAAAAGTGTTCGAGGTCGGGCTGGCGAT
CATCGTGGCGATCGCGCTTTTGGGAAGCGGTTTTTCGCTTGGTTGGAGCGCTGGCAGTAA
```

## **Modules:**

#### Modules:
![Modules_1](https://github.com/coreykirkland/metaMAG_test/blob/e9061dbffec80597f34860dab92594fa9b759654/metaMAG.drawio(2).svg)  

#### Pipeline:
![pipeline_1](https://github.com/coreykirkland/metaMAG_test/blob/33e65ee534199bd91a69a94bc4d89b915a0b2cae/metaMAG.drawio(1).svg)  



## 1. metaMAG_setup module:
* Calls genes in metagenome assembly - Prodigal.
* Calculates alignment statistics and removes duplicate reads - Picard.
* Counts the number of reads aligned to each gene - HTSeq-Count.
* Normalises gene reads by Transcripts Per Million (TPM) - https://github.com/EnvGen/metagenomics-workshop

#### Usage:
```
bash metaMAG_setup.sh -m <Metagenome Name> -c <Contigs File> -a <Alignment File> -j <PATH to Java> -o <Output Directory>
```
metaMAG Module: metaMAG_setup.sh  
-m: Metagenome name (must be one word with no spaces or special characters, e.g. MG1)  
-c: Contigs file from assembly step (.fa or .fasta)  
-a Alignment/mapping file (.bam)  
-j PATH to Java (required to Picard).  
-o: Output directory (this is where a folder called “metaMAG” will be created and contain all output files for all modules).  
Note: All arguments required to successfully run the module.  

#### Outputs:
##### **Prodigal Output: .faa**
```
>AcS5_NODE_1_length_1221932_cov_20.113987_1 # 2 # 1594 # 1 # ID=1_1;partial=10;start_type=Edge;rbs_motif=None;rbs_spacer=None;gc_cont=0.666
LMKALASELGVEMISIKCSDLMSKWYGESENRVADLLRTARERAPCILFMDEIDAVAKRR
DMYTADDVTPRLLSILLSEMDGIDKSAGVMVVGSTNKPDLIDQALMRPGRLDKIIYVPPP
DFNERMEIIHVHLVGRPVANDIDLSEIAKKTERFSGADLANLVREGATIAVRREMMTGVR
APIAMDDFRQIMGRIKPSISLRMIADYETMKLDYERKMHQVQRMERKIVVKWDDVGGLID
```
##### **Prodigal Output: .fna**
```
>NODE_1_length_1221932_cov_20.113987_1 # 2 # 1594 # 1 # ID=1_1;partial=10;start_type=Edge;rbs_motif=None;rbs_spacer=None;gc_cont=0.666
CTGATGAAGGCGCTCGCGAGCGAGCTCGGCGTCGAGATGATCTCGATCAAGTGCAGCGATCTGATGAGCA
AGTGGTACGGCGAGTCGGAGAACCGCGTCGCCGACCTTCTGCGCACCGCCCGAGAGCGGGCCCCGTGCAT
CCTGTTCATGGACGAGATCGACGCGGTGGCCAAGCGCCGCGACATGTACACCGCGGACGATGTCACGCCC
CGGCTGCTGAGCATCCTGCTCAGCGAGATGGACGGGATCGACAAGTCGGCGGGCGTGATGGTCGTCGGCT
```
##### **Prodigal Output: .gff**
```
##gff-version  3
# Sequence Data: seqnum=1;seqlen=1221932;seqhdr="NODE_1_length_1221932_cov_20.113987"
# Model Data: version=Prodigal.v2.6.3;run_type=Metagenomic;model="13|Catenulispora_acidiphila_DSM_44928|B|69.8|11|1";gc_cont=69.80;transl_table=11;uses_sd=1
NODE_1_length_1221932_cov_20.113987     Prodigal_v2.6.3 CDS     2       1594    321.5   +  0ID=1_1;partial=10;start_type=Edge;rbs_motif=None;rbs_spacer=None;gc_cont=0.666;conf=99.99;score=321.47;cscore=318.25;sscore=3.22;rscore=0.00;uscore=0.00;tscore=3.22;
NODE_1_length_1221932_cov_20.113987     Prodigal_v2.6.3 CDS     1729    2070    27.0    +  0ID=1_2;partial=00;start_type=ATG;rbs_motif=None;rbs_spacer=None;gc_cont=0.719;conf=99.80;score=26.98;cscore=27.80;sscore=-0.82;rscore=-4.48;uscore=-0.87;tscore=4.54;
```
##### **GTF File: map.gtf***
```
NODE_1_length_1221932_cov_20.113987     Prodigal_v2.6.3 CDS     2       1594    .       +       .       gene_id 1_1
NODE_1_length_1221932_cov_20.113987     Prodigal_v2.6.3 CDS     1729    2070    .       +       .       gene_id 1_2
NODE_1_length_1221932_cov_20.113987     Prodigal_v2.6.3 CDS     2098    5868    .       +       .       gene_id 1_3
NODE_1_length_1221932_cov_20.113987     Prodigal_v2.6.3 CDS     5865    9338    .       +       .       gene_id 1_4
NODE_1_length_1221932_cov_20.113987     Prodigal_v2.6.3 CDS     9465    13007   .       +       .       gene_id 1_5
```
##### **Gene Count: .count**
```
100000_1        16
100000_2        12
100000_3        15
100000_4        31
100000_5        15
```
##### **Gene Lengths: .genelengths**
```
1_1     1593
1_2     342
1_3     3771
1_4     3474
1_5     3543
```
##### **Gene TPM: .tpm**
```
gene_id AcS5    AcS5
58444_3 0.026679310668686264    AcS5
199562_2        0.11971582727610783     AcS5
44805_3 0.27201702765695507     AcS5
161567_2        0.04380454386818083     AcS5
```

## 2. metaMAG_cluster module:
* Clusters amino acid sequences from all MGs into protein families - MMseqs2.
* Calculates MMseqs2 statistics - R script.

##### Usage:
```
bash metaMAG_cluster.sh -t <No. of Threads> -o <Output Directory>
```
metaMAG Module: metaMAG_cluster.sh    
-t: Number of threads for MMseqs2 program.  
-o: Output directory (must be the same as used in previous module).  
Note: All arguments required to successfully run the module.  

#### Outputs:
##### **Combined and modified Prodigal AA File: Combined_AA_1.fasta**
```
>AcS5_NODE_1_1_GeneID=1_1
LMKALASELGVEMISIKCSDLMSKWYGESENRVADLLRTARERAPCILFMDEIDAVAKRR
DMYTADDVTPRLLSILLSEMDGIDKSAGVMVVGSTNKPDLIDQALMRPGRLDKIIYVPPP
DFNERMEIIHVHLVGRPVANDIDLSEIAKKTERFSGADLANLVREGATIAVRREMMTGVR
APIAMDDFRQIMGRIKPSISLRMIADYETMKLDYERKMHQVQRMERKIVVKWDDVGGLID
```
##### **MMSeqs2 Output: allMG_AA_cluster.tsv**
```
AcS5_NODE_289734_1_GeneID=289734_1      AcS5_NODE_289734_1_GeneID=289734_1
AcS5_NODE_289750_1_GeneID=289750_1      AcS5_NODE_289750_1_GeneID=289750_1
AcS5_NODE_289765_3_GeneID=289765_3      AcS5_NODE_289765_3_GeneID=289765_3
AcS5_NODE_289777_3_GeneID=289777_3      AcS5_NODE_289777_3_GeneID=289777_3
AcS5_NODE_289777_3_GeneID=289777_3      AcS5_NODE_67580_4_GeneID=67580_4
```
##### **MMSeqs2 Output: test_cluster_repseq.fasta**
```
>AcS5_NODE_1_1_GeneID=1_1
LMKALASELGVEMISIKCSDLMSKWYGESENRVADLLRTARERAPCILFMDEIDAVAKRRDMYTADDVTPRLLSILLSEMDGIDKSAGVMVVGSTNKPDLIDQALMRPGRLDKIIYVPPPDFNERMEIIHVHLVGRPVANDIDLSEIAKKTERFSGADLANLVREGATIAVRREMMTGVRAPIAMDDFRQIMGRIKPSISLRMIADYETMKLDYERKMHQVQRMERKIVVKWDDVGGLIDIKTAIREYVELPLTRPELMESYKIKTGRGILLFGPPGCGKTHIMRAAANELNVPMQIVNGPELVSALAGQSEAAVRDVLYRARENAPSIVFFDEIDALASRESMKTPEVSRAVSQFLTEMDGLRPKDKVIIIATTNRPQMLDPALLRPGRFDKIFYVPPPDLDARQDIFRIHMKGVPAEGAIDFGDLAGRSEGFSGADIASVVDEAKLIALREQLAVELSEGPNARSAAMGGLFTASSTPTAAAKIEPVSKVVGVRMANLLEAVGKTKTSITRETLAWAEEFIRSYGTRA*
```
##### **MMSeqs2 Statistics: MmseqsStats.tsv**
```
"Singletons"    "Percent_Singletons"    "MultiGene_GF"  "Percent_MultiGene_GF"  "Total"
734841  77.7133375423947        210738  22.2866624576053        945579
```
##### **MMSeqs2 Statistics: MmseqsHistogram.pdf**
Histogram of MMSeqs2 statistics.

## 3. metaMAG_kofam module:
* Functionally annotates the representative protein family sequences from the MMseqs2 output - Kofam Scan.

##### Usage:
```
bash metaMAG_kofam.sh -k <KO List> -p <Profile> -t <No. of Threads> -o <Output Directory>
```
metaMAG module: metaMAG_kofam.sh  
-k: KO list (required for Kofam Scan - see https://github.com/takaram/kofam_scan) 
-p: Profile (required for Kofam Scan - see https://github.com/takaram/kofam_scan)  
-t: Number of threads.  
-o: Output directory (must be the same as used in previous module).  

#### Output:
##### **Kofam Scan Output:**
```
FILE
```
## 4. metaMAG_gene module:
* Integrates gene family (GF) and KEGG Orthology (KO) with TPM data - R script (TPM.R).

##### Usage:
```
bash metaMAG_gene.sh -m <Metagenome Name> -k <Kofam Output> -o <Output Directory>
```
metaMAG module: metaMAG_gene.sh  
-m: Metagenome name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).  
-k: Kofam output file (two column file containing name and KO k number)  NOT REQUIRED??  
-o: Output directory (must be the same as used in previous module).  

##### Output:
(Output files)



## 5. metaMAG_genome module:
* Calculates the percentage of reads for a GF or KO (two separate tables) that belongs to a MAG in a metagenome.

##### Usage:
```
bash metaMAG_genome.sh -m <Metagenome Name> -b <Bin Directory> -o <Output Directory>
```
metaMAG module: metaMAG_genome.sh  
-m: Metagenome Name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).  
-b: Bin directory - PATH to directory containing .fa files from binning step. (More details needed).  
-o: Output directory (must be the same as used in previous module).  

##### Output:
(Output files)



## 6. metaMAG_strain module:
* Calculates population genetic statistics (SNVs, nucleotide diversity, pNpS ratios) - inStrain.
* Integrates statistics with GFs and MAGs - R script.
* Optional module - computationally expensive with large datasets.

##### Usage:
```
bash metaMAG_strain.sh -m <Metagenome Name> -a <Alignment File> -c <Contigs File> -t <No. of Thread> -o <Output Directory>
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
* Scripts for the analysis and visualisation of data from the **metaMAG_genome** module

## 1. metaMAG_visualisation_setup
* Combines data produced during metaMAG_genome with KEGG information (selected KOs and all KOs from the KEGG database) and MAG classification.
* Run this script once to setup files required for the below visualisation scripts.
* Requires a table of MAG classification - see below and table provided:

```
MAG	Depth	Bacteria	Phylum	Class	Order	Family	Genus	Species
AcS1-1	Surface	d__Bacteria	p__Acidobacteriota	c__Acidobacteriae	o__UBA7541	f__UBA7541	g__	s__
AcS1-10	Surface	d__Bacteria	p__Desulfobacterota_B	c__Binatia	o__Binatales	f__Binataceae	g__	s__
AcS1-11	Surface	d__Bacteria	p__Verrucomicrobiota	c__Verrucomicrobiae	o__Pedosphaerales	f__Pedosphaeraceae	g__UBA11358	s__
AcS1-12	Surface	d__Bacteria	p__Proteobacteria	c__Gammaproteobacteria	o__SLND01	f__	g__	s__
```
##### Usage:
```
bash metaMAG_visualisation_setup.sh -o <Output Directory>
```
metaMAG module: metaMAG_visualisation_setup.sh  
-o: Output directory (must be the same as used in previous modules).  
Ensure files are in the same location as created during metaMAG_genome module

## 2. metaMAG_visualisation_barchart
* Produces a bar chart for a given KO (e.g. KO1944) and taxonomy level (e.g. Phylum)
* Requires MergedKOAll.tsv file from metaMAG_visualisation_setup.

##### Usage:
```
bash metaMAG_visualisation_barchart.sh -k <KEGG K-Number> -b <Taxon Level> -o <Output Directory>
```
metaMAG module: metaMAG_visualisation_barchart.sh  
-k: KEGG k-number (e.g. KO1944).  
-b: Taxon level (based on column name). E.g. Domain Phylum Class Order Family Genus Species or MAG 
-o: Output directory (must be the same as used in previous modules).  

## 2. metaMAG_visualisation_heatmap
* Produces a heatmap for MAGs from a given order using a database of selected KOs. 
* Requires MergedGF.tsv and MergedKO.tsv files from metaMAG_visualisation_setup.

##### Usage:
```
bash etaMAG_visualisation_heatmap.sh -t <Order Name> -p <Greater Than Percentage> -o <Output Directory> 
```
metaMAG module: metaMAG_visualisation_heatmap.sh  
-t: Name of order based on MAG classification table (e.g. o__Solirubrobacterales)  
-p: Include GFs/KOs with at least one MAG greater than "percentage" (e.g. 50)  
-o: Output directory (must be the same as used in previous modules).  

