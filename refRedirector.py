#!/usr/local/bin/ python3
# Refer to FASTA file, redirect NULL data in VCF file's ref column 
# to the actual base of the start location of variants in reference genome 
import argparse
import pysam
from pysam import VariantFile

# Parse FASTA file name and VCF file name
parser = argparse.ArgumentParser(description="Refer to FASTA file, redirect NULL data in VCF file's ref column.")
parser.add_argument('fna_file', type=str, help="The name of FASTA file")
parser.add_argument('vcf_file', type=str, help="The name of VCF file")
args = parser.parse_args()
fna_file = args.fna_file
vcf_file = args.vcf_file
# Generate the rereferenced VCF file name
vcf_out_file = vcf_file.replace("vcf", "REREF.vcf")

# creat I/O objects
vcf_in = VariantFile(vcf_file, 'r')
vcf_out = VariantFile(vcf_out_file, 'w', header=vcf_in.header)

i = 0 # counter of changed records
for rec in vcf_in.fetch():
    # using samtools faidx to search FASTA file,
    # get the base of chromosome on the start position, then trim the result and uppercase
    base = pysam.faidx(fna_file, rec.chrom + ':' + str(rec.pos) + '-' + str(rec.pos))
    base = base.replace('\n', '')
    base = base.replace('>' + rec.chrom + ':' + str(rec.pos) + '-' + str(rec.pos), '').upper()
    # modify the reference allele
    if base.upper() != 'N':
        rec.ref = base
        vcf_out.write(rec)
        # print("Changed reference of " + rec.chrom + " on " + str(rec.pos) + " to " + base + ".")
        i += 1

vcf_in.close()
vcf_out.close()
print("Wrote %d rec in total." % i)