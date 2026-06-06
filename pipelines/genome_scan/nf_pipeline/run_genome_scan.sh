#!/bin/bash
#SBATCH --job-name=genome_scan
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --account=nn10082k
#SBATCH --output=genome_scan_%j.out

module purge
module load R/4.5.2-gfbf-2025b

# Move to correct directory
echo "Starting job $SLURM_JOB_ID on $(hostname)"

# Run R script with FULL PATH
Rscript /cluster/work/users/melatag/genotyping_pipeline/output/genome_scan/nf_pipeline/genome_scan_pipeline.R


