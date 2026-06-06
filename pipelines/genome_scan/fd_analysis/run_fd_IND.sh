#!/bin/bash
#SBATCH --job-name=fd_IND
#SBATCH --output=fd_IND_%j.out
#SBATCH --error=fd_IND_%j.err
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

# STEP 1: Convert VCF → GENO (ONLY if not already done)
#if [ ! -f dataset.geno.gz ]; then
# echo "Converting VCF to GENO..."
# python parseVCF.py \
# -i clean.vcf.gz \
# -o dataset.geno.gz
#else
# echo "GENO file already exists, skipping conversion."
#fi

# STEP 2: Run fd (India as P1)
echo "Running fd analysis (India as P1)..."

python ABBABABAwindows.py \
 -g variants_default_filters.geno.gz \
 -f phased \
 -o fd_IND_SA_EU_1kb.csv \
 -w 1000 \
 -s 1000 \
 -m 10 \
 -P1 India \
 -P2 South_Africa \
 -P3 Norway \
 -O Outgroup \
 --popsFile pops_fd_final.txt \
 --minData 0.5 \
 -T 2

echo "END: $(date)"
