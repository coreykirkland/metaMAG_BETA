# 1) metaMAG_setup.sh module: requires prodigal, picard, htseq, pandas-0.24.2. Scripts: prodigalgff2gtf.sh tpm_table.py

sh metaMAG_setup.sh -m MG1 -c home/MG1/MG1_Contigs.fa -a MG1/MG1_Alignment.bam -j Jarva_PATH -o home/

# 2) metaMAG_cluster.sh module: requires MMSeqs2, R (works with version 4.0.2). Scripts: Mmseqs2Stats.R
sh metaMAG_cluster.sh -m MG1 -t 20 -o home/

# 3) metaMAG_kofam.sh module: requires Kofam Scan, KEGG database,
sh metaMAG_kofam.sh -k home/KEGG/KO_List -p home/KEGG/profile -t 20 -o home/

# 4) metaMAG_gene.sh module: requires R (works with version 4.0.2). Scripts: TPM.R
sh metaMAG_gene.sh -m MG1 -k home/KOFAM_SCAN/Kofam.output -o home/

# 5) metaMAG_genome.sh module: requires R (works with version 4.0.2). Scripts: MAGPercent.R
sh metaMAG_genome.sh -m MG1 -b /home/BIN_DIR/MG1_BIN_DIR/ -o home/

# Optional) metaMAG_strain.sh module: requires inStrain_v1.5.3, R (works with version 4.0.2). Scripts: SNV.R
sh metaMAG_strain.sh -m MG1 -a MG1/MG1_Alignment.bam -c home/MG1/MG1_Contigs.fa -t 20 -o /home