#!/bin/bash

infile=$1

if [ "$infile" == "" ] ; then
    echo "Usage: prodigalgff2gtf.sh <Prodigal gff file>"
    exit 0
fi

grep -v "#" $infile | grep "ID=" | cut -f1 -d ';' | sed 's/ID=//g' | cut -f1,4,5,7,9 |  awk -v OFS='\t' '{print $1,"Prodigal_v2.6.3","CDS",$2,$3,".",$4,".","gene_id " $5}'