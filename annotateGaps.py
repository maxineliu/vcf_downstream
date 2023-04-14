#!/usr/bin/env python3
#This script takes a fasta file and prints the gaps(Ns) regions in BED3 format.
#Usage: python3 3.annotateGaps.py <fasta file>

# Import necessary packages
import argparse
import re
from Bio import SeqIO

# Parse command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("fasta") # FASTA file
args = parser.parse_args()

# Open FASTA, search for masked regions, print in BED3 format
with open(args.fasta) as handle:
    for record in SeqIO.parse(handle, "fasta"):
        for match in re.finditer('N+', str(record.seq)):
            print(record.id, match.start(), match.end(), sep='\t')