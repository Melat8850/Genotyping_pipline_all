#!/bin/bash
#SBATCH --job-name=treemix_step1
#SBATCH --account=nn10082k
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=3:00:00
#SBATCH --output=step1_%j.out
#SBATCH --error=step1_%j.err

set -o errexit
set -o nounset

echo "START STEP1: $(date)"

module purge
module load TreeMix/1.13-GCC-12.3.0
module load parallel/20230722-GCCcore-12.3.0

cd /cluster/work/users/melatag/genotyping_pipeline/output/treemix/TreeMix

sh Step1_TreeMix.sh \
    variants_default_filters.noN.LDpruned.treemix.frq.gz \
    4 \
    100 \
    PMON_NOR \
    100 \
    /cluster/work/users/melatag/genotyping_pipeline/output/treemix/TreeMix/phylip-3.697/exe/consense \
    sparrow \
    1 \
    5 \
    5

echo "END STEP1: $(date)"
