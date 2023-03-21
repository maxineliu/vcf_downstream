# vcf_downstream
scripts for analysis after sv calling

## refRedirector.py
The SV calling package, sniffles2, generates VCF where the REF column is filled in "N"s. But to build a pangenome, the the real base of REF column is necessary. So this script is to replace "N"s in REF col with real base which is searched from reference genome.
INPUT: VCF file, reference genome
OUTPUT: modified VCF file
