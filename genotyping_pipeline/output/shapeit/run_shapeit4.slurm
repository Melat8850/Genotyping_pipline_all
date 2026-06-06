#!/bin/bash
#SBATCH --job-name=shapeit4_sparrow
#SBATCH --account=nn10082k
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --array=1-30
#SBATCH --output=logs/shapeit_%A_%a.out
#SBATCH --error=logs/shapeit_%A_%a.err

# Load modules (FIXED ORDER / NO CONFLICT)
module --force purge
module load StdEnv
module load SHAPEIT4/4.2.2-foss-2021a

# DEBUG
echo "PATH = $PATH"
which shapeit4.2

# Files
CHR_LIST=chr_list.txt
MAP_DIR=/cluster/projects/nn10082k/recombination_maps

# Get chromosome for this job
CHR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CHR_LIST)

# Remove .vcf.gz to get chromosome name
CHR_NAME=$(basename $CHR .vcf.gz)

echo "======================================"
echo "Processing chromosome: $CHR_NAME"
echo "Input VCF: $CHR"
echo "Map file: $MAP_DIR/${CHR_NAME}.map"
echo "======================================"

# Output prefix
OUT=${CHR_NAME}_phased

# Run SHAPEIT4  (FIXED LINE BREAKS)
shapeit4.2 \
  --input "$CHR" \
  --map "$MAP_DIR/${CHR_NAME}.map" \
  --region "$CHR_NAME" \
  --output "${OUT}.vcf.gz" \
  --thread 8

