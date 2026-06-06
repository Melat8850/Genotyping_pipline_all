#!/bin/bash
#SBATCH --job-name=fd_NOR_to_IND
#SBATCH --output=fd_NOR_to_IND_%j.out
#SBATCH --error=fd_NOR_to_IND_%j.err
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

echo "Running fd analysis (Norway introgression into India)..."

python ABBABABAwindows.py \
 -g variants_default_filters.geno.gz \
 -f phased \
 -o fd_NOR_to_IND_1kb.csv \
 -w 1000 \
 -s 1000 \
 -m 10 \
 -P1 cape_verde \
 -P2 India \
 -P3 Norway \
 -O Outgroup \
 --popsFile pops_fd_final.txt \
 --minData 0.5 \
 -T 2

echo "END: $(date)"
