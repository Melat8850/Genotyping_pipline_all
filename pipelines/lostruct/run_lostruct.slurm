#!/bin/bash
#SBATCH --job-name=lostruct_scan
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --time=24:00:00

# Load modules
module --force purge
module load StdEnv
module load gfbf/2025a
module load R/4.5.1-gfbf-2025a
module load BCFtools/1.22-GCC-14.2.0

# R library path
export R_LIBS_USER=/cluster/home/melatag/R/x86_64-pc-linux-gnu-library/4.5

# Chromosome argument (pass as: sbatch run_lostruct.slurm chr1)
CHR=$1
if [ -z "$CHR" ]; then
  echo "ERROR: No chromosome argument provided. Usage: sbatch run_lostruct.slurm <chr>"
  exit 1
fi

# Paths
VCF=/cluster/work/users/melatag/pipelines/filtered/${CHR}_filtered.vcf.gz
OUTDIR=/cluster/work/users/melatag/pipelines/lostruct/output
OUTPUT=${OUTDIR}/${CHR}
SAMPLES=/cluster/work/users/melatag/pipelines/keep_samples.txt

# Parameters
K=3
WINDOW=1000
CORES=2

echo "Running lostruct on chromosome: $CHR"
echo "VCF:     $VCF"
echo "Output:  $OUTPUT"
echo "Samples: $SAMPLES"

# Validate inputs
if [ ! -f "$VCF" ]; then
  echo "ERROR: VCF file not found: $VCF"
  exit 1
fi
if [ ! -f "$SAMPLES" ]; then
  echo "ERROR: Samples file not found: $SAMPLES"
  exit 1
fi

# Create output directory
mkdir -p $OUTDIR

# Confirm bcftools is available
which bcftools || { echo "ERROR: bcftools not found in PATH"; exit 1; }
bcftools --version | head -1

# Script path
SCRIPT=/cluster/work/users/melatag/pipelines/lostruct/lostruct_scan.R

# Run
Rscript $SCRIPT \
  -v $VCF \
  -k $K \
  -w $WINDOW \
  -c $CORES \
  -s $SAMPLES \
  -o $OUTPUT

echo "lostruct finished for $CHR"
