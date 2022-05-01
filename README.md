# **metaMAG**
### Integrating Metagenome and Metagenome-Assembled Genome Data


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

Example of the directory: 
(Check .fa file names do not contain underscores)
```
AcS5-100.fa  AcS5-118.fa  AcS5-16.fa  AcS5-34.fa  AcS5-51.fa  AcS5-69.fa  AcS5-86.fa
AcS5-101.fa  AcS5-119.fa  AcS5-17.fa  AcS5-35.fa  AcS5-52.fa  AcS5-6.fa   AcS5-87.fa
```
Example of a .fasta file:
```
>NODE_2_length_707815_cov_20.038156
TTGGTATCCACTTTCTGAAGCGGATGCGAATTGCCGAGAGGTTCAGGGGCCGACGGCCGC
AGGAGCCGTCGGCCCCCGTCTCCCCGGAGCAGTTCAGGAGAGATGGTTTTCTTTCCAAGC
CTTTGATACAATGGAGCCAATGGCAACCAGGAAAAAAGTGTTCGAGGTCGGGCTGGCGAT
CATCGTGGCGATCGCGCTTTTGGGAAGCGGTTTTTCGCTTGGTTGGAGCGCTGGCAGTAA
```

## **Modules:**

#### Modules:
![Modules_1](https://github.com/coreykirkland/metaMAG_test/blob/main/metaMAG.drawio(2).svg)  

#### Pipeline:
![pipeline_1](https://github.com/coreykirkland/metaMAG_test/blob/main/metaMAG.drawio(1).svg)  



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
##### **MMseqs2 Output: allMG_AA_cluster.tsv**
```
AcS5_NODE_289734_1_GeneID=289734_1      AcS5_NODE_289734_1_GeneID=289734_1
AcS5_NODE_289750_1_GeneID=289750_1      AcS5_NODE_289750_1_GeneID=289750_1
AcS5_NODE_289765_3_GeneID=289765_3      AcS5_NODE_289765_3_GeneID=289765_3
AcS5_NODE_289777_3_GeneID=289777_3      AcS5_NODE_289777_3_GeneID=289777_3
AcS5_NODE_289777_3_GeneID=289777_3      AcS5_NODE_67580_4_GeneID=67580_4
```
##### **MMseqs2 Output: test_cluster_repseq.fasta**
```
>AcS5_NODE_1_1_GeneID=1_1
LMKALASELGVEMISIKCSDLMSKWYGESENRVADLLRTARERAPCILFMDEIDAVAKRRDMYTADDVTPRLLSILLSEMDGIDKSAGVMVVGSTNKPDLIDQALMRPGRLDKIIYVPPPDFNERMEIIHVHLVGRPVANDIDLSEIAKKTERFSGADLANLVREGATIAVRREMMTGVRAPIAMDDFRQIMGRIKPSISLRMIADYETMKLDYERKMHQVQRMERKIVVKWDDVGGLIDIKTAIREYVELPLTRPELMESYKIKTGRGILLFGPPGCGKTHIMRAAANELNVPMQIVNGPELVSALAGQSEAAVRDVLYRARENAPSIVFFDEIDALASRESMKTPEVSRAVSQFLTEMDGLRPKDKVIIIATTNRPQMLDPALLRPGRFDKIFYVPPPDLDARQDIFRIHMKGVPAEGAIDFGDLAGRSEGFSGADIASVVDEAKLIALREQLAVELSEGPNARSAAMGGLFTASSTPTAAAKIEPVSKVVGVRMANLLEAVGKTKTSITRETLAWAEEFIRSYGTRA*
```
##### **MMseqs2 Statistics: MmseqsStats.tsv**
```
"Singletons"    "Percent_Singletons"    "MultiGene_GF"  "Percent_MultiGene_GF"  "Total"
734841  77.7133375423947        210738  22.2866624576053        945579
```
##### **MMseqs2 Statistics: MmseqsHistogram.pdf**
Histogram of MMseqs2 statistics.

## 3. metaMAG_kofam module:
* Functionally annotates the representative protein family sequences from the MMseqs2 output (all MGs) - Kofam Scan.

##### Usage:
```
bash metaMAG_kofam.sh -k <KO List> -p <Profile> -t <No. of Threads> -o <Output Directory>
```
metaMAG module: metaMAG_kofam.sh  
-k: KO list (required for Kofam Scan - see https://github.com/takaram/kofam_scan)  
-p: Profile (required for Kofam Scan - see https://github.com/takaram/kofam_scan)  
-t: Number of threads.  
-o: Output directory (must be the same as used in previous module).  
Note: All arguments required to successfully run the module.

#### Output:
##### **Kofam Scan Output: Kofam_Scan_Results_K.txt**
```
AcS5_NODE_1_193_GeneID=1_193    K22223
AcS5_NODE_1_737_GeneID=1_737    K19267
AcS5_NODE_1_929_GeneID=1_929    K02906
AcS5_NODE_2_125_GeneID=2_125    K00036
AcS5_NODE_2_125_GeneID=2_125    K00033
```
## 4. metaMAG_gene module:
* Integrates gene family (GF) and KEGG Orthology (KO) with TPM data for each MG - R script (TPM.R).

##### Usage:
```
bash metaMAG_gene.sh -m <Metagenome Name> -k <Kofam Output> -o <Output Directory>
```
metaMAG module: metaMAG_gene.sh  
-m: Metagenome name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).   
-o: Output directory (must be the same as used in previous module).  

#### Output:
##### **Number of Genes in each Gene Family: ClusterCount.tsv**
```
AcS5_NODE_1_1_GeneID=1_1        4
AcS5_NODE_1_1001_GeneID=1_1001  1
AcS5_NODE_1_1002_GeneID=1_1002  1
AcS5_NODE_1_1003_GeneID=1_1003  1
AcS5_NODE_1_1004_GeneID=1_1004  1
```
##### **Gene TPM Table: GeneTPM.tsv**
```
MG_GeneID       MG      GF      GF_Member       TPM
AcS5_1_1        AcS5    AcS5_NODE_1_1_GeneID=1_1        AcS5_NODE_1_1_GeneID=1_1        0.799701032501215
AcS5_1_10       AcS5    AcS5_NODE_899_26_GeneID=899_26  AcS5_NODE_1_10_GeneID=1_10      0.939016452285368
AcS5_1_100      AcS5    AcS5_NODE_1261_19_GeneID=1261_19        AcS5_NODE_1_100_GeneID=1_1000.760084361188572
AcS5_1_1000     AcS5    AcS5_NODE_10896_1_GeneID=10896_1        AcS5_NODE_1_1000_GeneID=1_1000      0.615710795376218
```
##### **Total TPM Table: TotalTPM.tsv**
```
GF      MG      TotalTPM
AcS5_NODE_1_1_GeneID=1_1        AcS5    1.32258006388587
AcS5_NODE_1_1001_GeneID=1_1001  AcS5    1.75218175472723
AcS5_NODE_1_1002_GeneID=1_1002  AcS5    0.950105451485715
AcS5_NODE_1_1003_GeneID=1_1003  AcS5    0.669220386321627
```
##### **Percent TPM Table: PercentTPM.tsv**
```
MG_KO   GF      MG      GF_Member       MG_GeneID       TPM     TotalTPM        Percent_GF KO       TotalTPM_KO     Percent_KO
AcS5_K00003     AcS5_NODE_7239_6_GeneID=7239_6  AcS5    AcS5_NODE_414290_1_GeneID=414290_1 AcS5_414290_1    0.0764513265623911      124.074520173174        0.0616172655398432      K00003      148.897865278025        0.0513448103635599
AcS5_K00003     AcS5_NODE_7239_6_GeneID=7239_6  AcS5    AcS5_NODE_197627_2_GeneID=197627_2 AcS5_197627_2    0.587999598156139       124.074520173174        0.47390841998458        K00003      148.897865278025        0.39490129496364
AcS5_K00003     AcS5_NODE_270876_2_GeneID=270876_2      AcS5    AcS5_NODE_127325_1_GeneID=127325_1  AcS5_127325_1   0.214671274585787       0.535960944260959       40.0535294380076   K00003   148.897865278025        0.144173507246023
AcS5_K00003     AcS5_NODE_7239_6_GeneID=7239_6  AcS5    AcS5_NODE_3071_27_GeneID=3071_27   AcS5_3071_27     0.744575611086526       124.074520173174        0.600103558770408       K00003      148.897865278025        0.500057948914336
```


## 5. metaMAG_genome module:
* Calculates the percentage of the reads for a GF or KO (two separate tables) that belong to a given MAG in within the MG.

##### Usage:
```
bash metaMAG_genome.sh -m <Metagenome Name> -b <Bin Directory> -o <Output Directory>
```
metaMAG module: metaMAG_genome.sh  
-m: Metagenome Name (must be one word with no spaces or special characters, e.g. MG1, and ensure the name is the same as the previous module).  
-b: Bin directory - PATH to directory containing .fa files from binning step. (More details needed).  
-o: Output directory (must be the same as used in previous module).  
Note: All arguments required to successfully run the module.

#### Output:
##### **Merged MAG Table: MG_MergedMAG.tsv**
```
Contig  MG      Bin     GeneID  MG_GeneID
NODE_1  AcS5    AcS5-107.fa     1_170   AcS5_1_170
NODE_1  AcS5    AcS5-107.fa     1_844   AcS5_1_844
NODE_1  AcS5    AcS5-107.fa     1_609   AcS5_1_609
NODE_1  AcS5    AcS5-107.fa     1_371   AcS5_1_371
```
##### **MAG Percent Table: MG_MAGPercent.tsv**
```
MG_GeneID       MG_KO   GF      MG.x    GF_Member       TPM     TotalTPM        Percent_GF      KO      TotalTPM_KO     Percent_KO Contig  MG.y    Bin     GeneID
AcS5_1_1000     AcS5_K03124     AcS5_NODE_10896_1_GeneID=10896_1        AcS5    AcS5_NODE_1_1000_GeneID=1_1000  0.615710795376218  78.394702775784 0.78539846899759        K03124  116.482527893902        0.528586395323631       NODE_1  AcS5    AcS5-107.fa        1_1000
AcS5_1_1005     AcS5_K01055     AcS5_NODE_188393_5_GeneID=188393_5      AcS5    AcS5_NODE_1_1005_GeneID=1_1005  0.945928726662353  47.5940730729894        1.98749269727702        K01055  351.00768586659 0.269489462695662       NODE_1  AcS5    AcS5-107.fa        1_1005
AcS5_1_1008     AcS5_K23356     AcS5_NODE_1893_7_GeneID=1893_7  AcS5    AcS5_NODE_1_1008_GeneID=1_1008  1.01441016647208  3.05806683998361 33.1716152573537        K23356  53.2377950342404        1.90543234523453        NODE_1  AcS5    AcS5-107.fa1_1008
AcS5_1_1010     AcS5_K01689     AcS5_NODE_46788_4_GeneID=46788_4        AcS5    AcS5_NODE_1_1010_GeneID=1_1010  0.701871096053131  253.067067507372        0.277345884222049       K01689  314.499197362365        0.223171029350653       NODE_1  AcS5       AcS5-107.fa     1_1010
```
##### **MAG Percent GF Table: MG_MAGPercentGF.tsv**
```
GF      MG_Bin  GFPercent
AcS5_NODE_100_123_GeneID=100_123        AcS5_AcS5-1.fa  4.01331090509955
AcS5_NODE_10024_10_GeneID=10024_10      AcS5_AcS5-1.fa  5.06239195109573
AcS5_NODE_100378_3_GeneID=100378_3      AcS5_AcS5-1.fa  9.32307468207402
AcS5_NODE_100573_3_GeneID=100573_3      AcS5_AcS5-1.fa  0.773759371111648
```
##### **MAG Percent KO Table: MG_MAGPercentKO.tsv**
```
KO      MG_Bin  KOPercent
K00003  AcS5_AcS5-1.fa  0.500057948914336
K00012  AcS5_AcS5-1.fa  0.703786698087246
K00014  AcS5_AcS5-1.fa  0.269474647403548
K00015  AcS5_AcS5-1.fa  1.07734819375613
```

## metaMAG Visualisation:  
* Scripts for the analysis and visualisation of data from the **metaMAG_genome** module

## 1. metaMAG_visualisation_setup
* Combines data produced during metaMAG_genome with KEGG information (selected KOs and all KOs from the KEGG database) and MAG classification.
* Run this script once to setup files required for the below visualisation scripts.
* Requires a table of MAG classification (named MAG_Taxonomy.tsv in working direcory) - see below for example table provided:

```
MAG	Depth	Bacteria	Phylum	Class	Order	Family	Genus	Species
AcS1-1	Surface	d__Bacteria	p__Acidobacteriota	c__Acidobacteriae	o__UBA7541	f__UBA7541	g__	s__
AcS1-10	Surface	d__Bacteria	p__Desulfobacterota_B	c__Binatia	o__Binatales	f__Binataceae	g__	s__
AcS1-11	Surface	d__Bacteria	p__Verrucomicrobiota	c__Verrucomicrobiae	o__Pedosphaerales	f__Pedosphaeraceae	g__UBA11358	s__
AcS1-12	Surface	d__Bacteria	p__Proteobacteria	c__Gammaproteobacteria	o__SLND01	f__	g__	s__
```
MAG_Taxonomy.tsv SelectedKOs.tsv AllKOs.tsv

##### Usage:
```
bash metaMAG_visualisation_setup.sh -o <Output Directory>
```
metaMAG module: metaMAG_visualisation_setup.sh  
-o: Output directory (must be the same as used in all previous modules).  
Ensure files are in the same location as created during metaMAG_genome module
Note: All arguments required to successfully run the module.

#### Output:
* MergedGF.tsv and MergedKO.tsv (selected KOs). Used in heatmap script.
* MergedGFAll.tsv and MergedKOAll.tsv (All KOs). Used in bar chart script.
##### MergedGF.tsv
```
KO      MAG     GF      GFPercent       MG      Depth   Bacteria        Phylum  Class   Order   FamilyGenus    Species Pathway.Name    Function        KO_Title        Gene
K00148  AcS5-27 AcS5_NODE_84326_4_GeneID=84326_4        3.2350060715427 AcS5    Surface d__Bacteria   p__Verrucomicrobiota     c__Verrucomicrobiae     o__Pedosphaerales       f__Pedosphaeraceae      g__UBA11358    s__     Carbon Metabolism       CH2O_Oxidation  fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46] fdhA
K00148  AcS5-41 AcS5_NODE_84326_4_GeneID=84326_4        2.29795616412416        AcS5    Surface d__Bacteria    p__Acidobacteriota      c__Acidobacteriae       o__Acidobacteriales     f__SCQP01       g__   s__      Carbon Metabolism       CH2O_Oxidation  fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46] fdhA
K00148  Unbinned        AcS5_NODE_84326_4_GeneID=84326_4        77.5854913091961        AcS5    NA    NA       NA      NA      NA      NA      NA      NA      Carbon Metabolism       CH2O_Oxidation  fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46] fdhA
K00148  AcS5-94 AcS5_NODE_84326_4_GeneID=84326_4        1.17988655220708        AcS5    Surface d__Bacteria    p__Firmicutes_E c__Thermaerobacteria    o__     f__     g__     s__     Carbon Metabolism     CH2O_Oxidation   fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46]  fdhA

```
##### MergedKO.tsv
```
K00148  Unbinned        AcS5_NODE_84326_4_GeneID=84326_4        77.5854913091961        AcS5    NA    NA       NA      NA      NA      NA      NA      NA      Carbon Metabolism       CH2O_Oxidation  fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46] fdhA
K00148  AcS5-94 AcS5_NODE_84326_4_GeneID=84326_4        1.17988655220708        AcS5    Surface d__Bacteria    p__Firmicutes_E c__Thermaerobacteria    o__     f__     g__     s__     Carbon Metabolism     CH2O_Oxidation   fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46]  fdhA
[s03ck1@maxlogin1 Genome_Visualisation]$ ^C
[s03ck1@maxlogin1 Genome_Visualisation]$ head -n 5 MergedKO.tsv
KO      MAG     MG      KOPercent       Depth   Bacteria        Phylum  Class   Order   Family  Genus Species  Pathway.Name    Function        KO_Title        Gene
K00148  AcS5-78 AcS5    6.72294734141631        Surface d__Bacteria     p__Proteobacteria       c__Gammaproteobacteria o__Steroidobacterales   f__Steroidobacteraceae  g__     s__     Carbon Metabolism     CH2O_Oxidation   fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46]  fdhA
K00148  AcS5-94 AcS5    1.17988655220708        Surface d__Bacteria     p__Firmicutes_E c__Thermaerobacteria   o__     f__     g__     s__     Carbon Metabolism       CH2O_Oxidation  fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46] fdhA
K00148  AcS5-15 AcS5    4.27127423685424        Surface d__Bacteria     p__Acidobacteriota      c__Acidobacteriae      o__Acidobacteriales     f__SCQP01       g__     s__     Carbon Metabolism       CH2O_Oxidation fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46]  fdhA
K00148  AcS5-99 AcS5    1.48936499213025        Surface d__Bacteria     p__Actinobacteriota     c__Thermoleophilia     o__Solirubrobacterales  f__Solirubrobacteraceae g__Palsa-465    s__     Carbon Metabolism      CH2O_Oxidation  fdhA; glutathione-independent formaldehyde dehydrogenase [EC:1.2.1.46]  fdhA
```
##### MergedGFAll.tsv
```
KO      MAG     GF      GFPercent       MG      Depth   Bacteria        Phylum  Class   Order   FamilyGenus    Species KO_Details
K00003  AcS5-17 AcS5_NODE_265058_1_GeneID=265058_1      5.45454975319319        AcS5    Surface d__Bacteria    p__Firmicutes   c__Bacilli      o__Bacillales   f__Bacillaceae_A        g__Bacillus_BD  s__   hom; homoserine dehydrogenase [EC:1.1.1.3]
K00003  AcS5-97 AcS5_NODE_7239_6_GeneID=7239_6  0.346748694314834       AcS5    Surface d__Bacteria   p__Actinobacteriota      c__Acidimicrobiia       o__Acidimicrobiales     f__RAAP-2       g__Palsa-459  s__      hom; homoserine dehydrogenase [EC:1.1.1.3]
K00003  AcS5-61 AcS5_NODE_7239_6_GeneID=7239_6  0.934773488960412       AcS5    Surface d__Bacteria   p__Actinobacteriota      c__Thermoleophilia      o__Gaiellales   f__Gaiellaceae  g__PALSA-600    s__   hom; homoserine dehydrogenase [EC:1.1.1.3]
K00003  AcS5-57 AcS5_NODE_7239_6_GeneID=7239_6  0.524984929091241       AcS5    Surface d__Bacteria   p__Actinobacteriota      c__Actinomycetia        o__Streptosporangiales  f__Streptosporangiaceae g__Palsa-506   s__     hom; homoserine dehydrogenase [EC:1.1.1.3]
```
##### MergedKOAll.tsv
```
KO      MAG     MG      KOPercent       Depth   Bacteria        Phylum  Class   Order   Family  Genus Species  KO_Details
K00003  AcS5-117        AcS5    0.0675447720104874      Surface d__Bacteria     p__Bacteroidota c__Bacteroidia o__Chitinophagales      f__Chitinophagaceae     g__UBA8621      s__     hom; homoserine dehydrogenase [EC:1.1.1.3]
K00003  AcS5-39 AcS5    1.69546715733237        Surface d__Bacteria     p__Actinobacteriota     c__Acidimicrobiia      o__Acidimicrobiales     f__RAAP-2       g__RAAP-2       s__     hom; homoserine dehydrogenase [EC:1.1.1.3]
K00003  AcS5-111        AcS5    0.194651196371218       Surface d__Bacteria     p__Eremiobacterota    c__Eremiobacteria        o__UBP12        f__UBA5184      g__     s__     hom; homoserine dehydrogenase [EC:1.1.1.3]
K00003  AcS5-9  AcS5    1.0407462623531 Surface d__Bacteria     p__Actinobacteriota     c__Thermoleophilia     o__Solirubrobacterales  f__Solirubrobacteraceae g__Palsa-744    s__     hom; homoserine dehydrogenase [EC:1.1.1.3]
```

## 2a. metaMAG_visualisation_barchart
* Produces a bar chart for a given KO (e.g. KO1944) and taxonomy level (e.g. Phylum)
* Requires MergedKOAll.tsv file from metaMAG_visualisation_setup.

##### Usage:
```
bash metaMAG_visualisation_barchart.sh -k <KEGG K-Number> -b <Taxon Level> -o <Output Directory>
```
metaMAG module: metaMAG_visualisation_barchart.sh  
-k: KEGG k-number (e.g. KO1944).  
-b: Taxon level (based on column name). E.g. Domain Phylum Class Order Family Genus Species or MAG (i.e. column name). 
-o: Output directory (must be the same as used in all previous modules).  
Note: All arguments required to successfully run the module.

## 2b. metaMAG_visualisation_heatmap
* Produces a heatmap for MAGs from a given order using a database of selected KOs. 
* Requires MergedGF.tsv and MergedKO.tsv files from metaMAG_visualisation_setup.

##### Usage:
```
bash metaMAG_visualisation_heatmap.sh -t <Order Name> -p <Greater Than Percentage> -o <Output Directory> 
```
metaMAG module: metaMAG_visualisation_heatmap.sh  
-t: Name of order based on MAG classification table (e.g. o__Solirubrobacterales)  
-p: Include GFs/KOs with at least one MAG greater than "percentage" (e.g. 50)  
-o: Output directory (must be the same as used in all previous modules).  
Note: All arguments required to successfully run the module.
