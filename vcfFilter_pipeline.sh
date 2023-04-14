#! /bin/bash
# Usage: ./vcfFiler_pipeline.sh <vcf file> <ref genome> 
# This script is to filter VCF file. The pocess is:
# Step one: 1) exclude SVs whose chromosome name starts with NW_; 2) exclude BND SVs (difficult to analysis so leave them for now); 3) keep SVs that pass all filters; 4) keep SVs that SVLEN < 100kb, supporting reads < 60, optional MAF > 0.05, optional F_MISSING < 0.2; 
# Step two: exclude SVs that located in identical locus; 
# Step three: intersect the last VCF with BED file containing gaps locations. 
# Step four: redirect "N" in REF column of vcf file to the actual base from ref genome.

filename=`basename $1 .vcf`

if [ $# -lt 1 ]; then
    echo "Error. Usage: ./vcfFiler.sh <vcf file>"
fi

## load module
#module load bcftools bedtools

IN_SV=$(bcftools view -H $1 | wc -l)
echo "The number of variants in the input VCF is $IN_SV"  

SAMPLE_NUM=$(grep -m1 "^#CHROM" $1 | awk -v FS="\t" '{for(i=1;i<=NF;i++) if($i=="FORMAT") print NF-i}')
echo "The number of samples is $SAMPLE_NUM"

# Step 1: filter out SVs according to some conditions
if [ $SAMPLE_NUM != 1 ]; then
    echo "This is a population-scaled VCF"
    echo "The filtering process is:"
    echo "1) exclude SVs whose chromosome name starts with NW_;"
    echo "2) exclude BND SVs (difficult to analysis so leave them for now);" 
    echo "3) keep SVs that pass all filters;" 
    echo "4) keep SVs that SVLEN < 100kb, supporting reads < 60, MAF > 0.05, F_MISSING < 0.2."
    bcftools view -i 'CHROM !~ "^NW_" && TYPE!="BND" && FILTER=="PASS" && INFO/SVLEN<100000 && INFO/SVLEN>-100000 && INFO/SUPPORT<60 && MAF>0.05 && F_MISSING<0.2' $1 -o $filename.i.vcf 
    echo "Writing The filtered VCF in $filename.i.vcf"

else
    echo "This is an individual-scaled VCF"
    echo "The filtering process is:"
    echo "1) exclude SVs whose chromosome name starts with NW_;"
    echo "2) exclude BND SVs (difficult to analysis so leave them for now);"
    echo "3) keep SVs that pass all filters;"
    echo "4) keep SVs that SVLEN < 100kb, supporting reads < 60."
    bcftools view -i 'CHROM !~ "^NW_" && TYPE!="BND" && FILTER=="PASS" && INFO/SVLEN<100000 && INFO/SVLEN>-100000 && INFO/SUPPORT<60' $1 -o $filename.i.vcf
    echo "Writing The filtered VCF in $filename.i.vcf."
fi

INCLUDE_SV=$(bcftools view -H $filename.i.vcf | wc -l)
echo "The number of variants left after those filtering process is $INCLUDE_SV"

# Step 2: exclude SVs that located in identical locus
## print out duplicates CHROM and POS 
echo "Searching SVs that located in identical locus..."
bcftools view -H $filename.i.vcf | cut -f 1,2 | uniq -d > $TMPDIR/dupPOS.txt

## make a subset of repetitive SVs
bcftools view -T ${TMPDIR}/dupPOS.txt $filename.i.vcf -o $filename.i.rpt.vcf
REPETITION_NUM=$(bcftools view -H $filename.i.rpt.vcf | wc -l)
echo "Writing repetitive SVs in $filename.i.rpt.vcf"
echo "The number of repetitive SVs is $REPETITION_NUM"

## make a subset of excluding repetitions
bcftools view -T ^"${TMPDIR}/dupPOS.txt" $filename.i.vcf -o $filename.i.nrpt.vcf
NONREPETITION_NUM=$(bcftools view -H $filename.i.nrpt.vcf | wc -l)
echo "Writing filted and non-repetitive SVs in $filename.i.nrpt.vcf."
echo "The number of SVs after filtering and removing repetitions is $NONREPETITION_NUM" 

# Step 3: intersect the last VCF with BED file containing gaps locations
## make a BED file containing gaps locations
echo "searching the gaps(Ns) regions in ref genome..."
python3 annotateGaps.py $2 > $(basename $2).gaps.bed
echo "Writing the gaps(Ns) regions in ref genome in $(basename $2).gaps.bed"

## intersect the last VCF with BED file containing gaps locations
echo "Intersecting $filename.i.nrpt.vcf with BED file containing gaps locations..."
bedtools intersect -v -a $filename.i.nrpt.vcf -b $(basename $2).gaps.bed | cat <(grep '#' $filename.i.nrpt.vcf) - > $filename.newfiltered.vcf
INTERSECT_NUM=$(bcftools view -H $filename.newfiltered.vcf | wc -l)
echo "Writing the filtered + nonrepetitive + nogaps VCF in $filename.newfiltered.vcf"
echo "The number of SVs after filtering, removing repetitions and removing gaps is $INTERSECT_NUM"

# Step 4: redirect "N" in REF column of vcf file to the actual base from ref genome
echo "Redirect "N" in REF column of vcf file to the actual base from ref genome..." 
python3 refRedirector.py $2 $filename.newfiltered.vcf
REDIRECT_NUM=$(bcftools view -H $filename.newfiltered.reRef.vcf | wc -l)
echo "Writing the filtered + nonrepetitive + nogaps + reRef VCF in $filename.newfiltered.reRef.vcf"
echo "The number of SVs after filtering, removing repetitions, removing gaps and reRef is $REDIRECT_NUM"
echo "Compressing and indexing the final VCF..."
bcftools view -Oz -o $filename.newfiltered.reRef.vcf.gz $filename.newfiltered.reRef.vcf
bcftools index $filename.newfiltered.reRef.vcf.gz
echo “Compression and indexing done.”

echo "Pipeline finished!"