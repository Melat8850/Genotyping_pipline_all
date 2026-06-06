#!/bin/bash
#SBATCH --job-name=fd_analysis
#SBATCH --output=fd_%j.out
#SBATCH --error=fd_%j.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=24:00:00
#SBATCH --account=nn10082k

set -e
set -u

echo "START: $(date)"

# Load modules
module purge
module load Python/3.12.3-GCCcore-13.3.0
module load BCFtools/1.21-GCC-13.3.0

# Go to working directory
cd /cluster/work/users/melatag/genotyping_pipeline/output/genome_scan/fd_analysis

# STEP 1: Convert VCF → GENO
#echo "Converting VCF to GENO..."

#python parseVCF.py \
# -i ../clean.vcf.gz \
# -o dataset.geno.gz

# STEP 2: Run fd (ABBA-BABA)
echo "Running fd analysis..."

python ABBABABAwindows.py \
 -g variants_default_filters.geno.gz \
 -f phased \
 -o fd_MDG_SA_EU_clean.csv \
 -w 50000 \
 -s 10000 \
 -m 10 \
 -P1 Madagascar \
 -P2 South_Africa \
 -P3 Norway \
 -O Outgroup \
 --popsFile pops_fd_final.txt \
 --minData 0.5 \
 -T 2

echo "END: $(date)"
