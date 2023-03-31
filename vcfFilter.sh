#! /bin/bash
# This script is to filter VCF through the process that: 1) exclude BND svs (difficult to analysis so leave them for now); 2) keep SVs that pass all filters; 3)  
#Usage: ./vcfFiler.sh <vcf file>

filename=`basename $1 .vcf`

if [ $# -lt 1 ]; then
    echo "Error. Usage: ./vcfFiler.sh <vcf file>"
fi

## load module
#module load StdEnv/2020 gcc/9.3.0 bcftools/1.16

## Exclude BND SVs 
# SV_type=(INS DEL DUP INV BND)
bcftools view -e 'INFO/SVTYPE="BND"' $1 -o $filename.notra.vcf

## Keep "PASS"
bcftools view -f "PASS" $1 -o $filename.notra.pass.vcf

## keep SVs that MAF > 0.05, SVLEN < 100kb, supporting reads < 60, F_MISSING < 0.2
bcftools view -i 'MAF>0.05 && INFO/SVLEN<100000 && INFO/SVLEN>-100000 && INFO/SUPPORT<60 && F_MISSING<0.2' $filename.notra.pass.vcf -o $filename.notra.pass.inc.vcf
bgzip -k $filename.notra.pass.inc.vcf
bcftools index $filename.notra.pass.inc.vcf.gz

## exclude unmapped scaffolds
bcftools view -r NC_058080.1,NC_058081.1,NC_058082.1,NC_058083.1,NC_058084.1,NC_058085.1,NC_058086.1,NC_058087.1,NC_058088.1,NC_058089.1,NC_058090.1,NC_008410.1 $filename.notra.pass.inc.vcf.gz -o $filename.notra.pass.inc.unmap.vcf

## exclude SVs that located in identical locus
### print out duplicates CHROM and POS 
bcftools view -H $filename.notra.pass.inc.unmap.vcf | cut -f 1,2 | uniq -d > $TMPDIR/dupPOS.txt

### make a subset of repetitive SVs
bcftools view -T ${TMPDIR}/dupPOS.txt $filename.notra.pass.inc.unmap.vcf -o $filename.notra.pass.inc.unmap.rpt.vcf

### make a subset of excluding repetitions
bcftools view -T ^"${TMPDIR}/dupPOS.txt" $filename.notra.pass.inc.unmap.vcf -o $filename.notra.pass.inc.unmap.nrpt.vcf
