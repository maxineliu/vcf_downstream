# vcf_downstream
scripts for analysis after sv calling

## vcfFilter_pipeline.sh
It's a pipeline for filtering vcf. To run `vcfFilter_pipeline.sh`, `annotateGaps.py` and `refRedirector.py` are required to be present in the same directory.The process is as follows:
Step one: 1) exclude SVs whose chromosome name starts with NW_; 2) exclude BND SVs (difficult to analysis so leave them for now); 3) keep SVs that pass all filters; 4) keep SVs that SVLEN < 100kb, supporting reads < 60, optional MAF > 0.05, optional F_MISSING < 0.2; 
Step two: exclude SVs that located in identical locus; 
Step three: intersect the last VCF with BED file containing gaps locations. 
Step four: redirect "N" in REF column of vcf file to the actual base from ref genome.

dependent tools: bedtools, bcftools
dependent python packages: argparse, biopython, re, pysam

usage: ./vcfFilter_pipeline.sh <vcf file> <ref genome> 