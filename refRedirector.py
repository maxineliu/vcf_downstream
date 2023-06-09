#!/usr/local/bin/ python3
# -*- coding: utf-8 -*-
# this script takes a fasta file and a vcf file, and redirect NULL data in VCF file's ref column to the actual base of the start location of variants. 
# usage: refRedirector.py [-h] fna_file vcf_file
 
# positional arguments:
#   fna_file    The name of FASTA file
#   vcf_file    The name of VCF file
# options:
#   -h, --help  show this help message and exit
# example: python3 refRedirector.py ref.fa input.vcf

import argparse
import pysam
from pysam import VariantFile

# Parse FASTA file name and VCF file name
parser = argparse.ArgumentParser(description="Refer to FASTA file, redirect NULL data in VCF file's ref column to the actual base of the start location of variants.")
parser.add_argument('fna_file', type=str, help="The name of FASTA file")
parser.add_argument('vcf_file', type=str, help="The name of VCF file")
args = parser.parse_args()
fna_file = args.fna_file
vcf_file = args.vcf_file
# Generate the output VCF file name
vcf_out_file = vcf_file.replace("vcf", "reRef.vcf")

# Creat I/O objects
vcf_in = VariantFile(vcf_file, 'r')
vcf_out = VariantFile(vcf_out_file, 'w', header=vcf_in.header)

i = 0 # counter of redirected records
for rec in vcf_in.fetch():
    # use samtools command faidx to search FASTA file, get the base on the start position, 
    # then trim the result to one character and uppercase
    # usage: samtools faidx ref.fa chr:from-to
    # output: >chr:from-to 
    base = pysam.faidx(fna_file, rec.chrom + ':' + str(rec.pos) + '-' + str(rec.pos))
    base = base.replace('\n', '')
    base = base.replace('>' + rec.chrom + ':' + str(rec.pos) + '-' + str(rec.pos), '').upper()
    # Write the record to the output file
    rec.ref = base
    vcf_out.write(rec)
    # Count if the record is redirected successfully
    if base != 'N':
        # print("Redirected reference of " + rec.chrom + " on " + str(rec.pos) + " to " + base + ".")
        i += 1

# Close I/O objects
vcf_in.close()
vcf_out.close()
print("Redirected %d records in total." % i)