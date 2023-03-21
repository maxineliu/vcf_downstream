#!/usr/local/bin/ python3
# This script is to replacement the "N"s in VCF ref column with the real base of the start location of variants in reference genome 
import pysam
from pysam import VariantFile

# change code based on your vcf input/output files and FASTA files
vcf_in = VariantFile("bufo1011.vcf", 'r')
vcf_out = VariantFile("bufo1011REREF.vcf", 'w', header=vcf_in.header)
fasta = "bufo1011.fna"

i = 0 # changed rec counter
for rec in vcf_in.fetch():
    # using samtools faidx to search FASTA file, get the base of chromosome on the start position
    base = ""
    base = pysam.faidx(fasta, rec.chrom + ":" + str(rec.pos) + "-" + str(rec.pos))
    base = base.replace('\n', '')
    base = base.replace('>' + rec.chrom + ":" + str(rec.pos) + "-" + str(rec.pos), '')
    # modify the reference allele
    if base.upper() != "N":
        rec.ref = base
        # print("Changed reference of " + rec.chrom + " on " + str(rec.pos) + " to " + base + ".")
        i += 1
    vcf_out.write(rec)

vcf_in.close()
vcf_out.close()
print("Wrote %d rec in total." % i)