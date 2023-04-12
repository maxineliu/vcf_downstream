#! /bin/bash
# This script is to intersect VCF file with BED file. The output is a VCF file with only SVs that NOT located in the BED regions.
VCF=
BED=
OUTVCF=
bedtools intersect -v -a $VCF -b $BED | cat <(grep '#' $VCF) - > $OUTVCF