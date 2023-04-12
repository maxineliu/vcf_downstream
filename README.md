# vcf_downstream
scripts for analysis after sv calling

## 1.vcfFilter.sh
This script is to filter VCF through the process that: 1) exclude BND svs (difficult to analysis so leave them for now); 2) keep SVs that pass all filters; 3) keep SVs that MAF > 0.05, SVLEN < 100kb, supporting reads < 60, F_MISSING < 0.2; 4) exclude unmapped scaffolds; 5) exclude SVs that located in identical locus 
INPUT: VCF file
OUTPUT: filtered VCF

## 2.refRedirector.py
The SV calling package, sniffles2, generates VCF where the REF column is filled in "N"s. But to build a pangenome, the the real base of REF column is necessary. So this script is to replace "N"s in REF col with real base which is searched from reference genome.
INPUT: VCF file, reference genome
OUTPUT: modified VCF file

## 3.annotateGaps.py
This script takes a fasta file and prints the gaps(Ns) regions in BED3 format.

## 4.intersectBedVcf.sh
This script is to intersect VCF file with BED file. The output is a VCF file with only SVs that NOT located in the BED regions.

