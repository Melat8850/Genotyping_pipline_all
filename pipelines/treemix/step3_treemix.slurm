#!/bin/bash
#SBATCH --job-name=treemix_step3
#SBATCH --account=nn10082k
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --time=12:00:00
#SBATCH --output=step3_%j.out
#SBATCH --error=step3_%j.err

set -o errexit
set -o nounset

echo "START STEP3: $(date)"

module purge
module load TreeMix/1.13-GCC-12.3.0
module load parallel/20230722-GCCcore-12.3.0

cd /cluster/work/users/melatag/genotyping_pipeline/output/treemix/TreeMix

sh Step3_TreeMix.sh \
    variants_default_filters.noN.LDpruned.treemix.frq.gz \
    4 \
    100 \
    PMON_NOR \
    100 \
    2 \
    sparrow \
    30 \
    sparrow_constree.newick \
    /cluster/work/users/melatag/genotyping_pipeline/output/treemix/TreeMix/phylip-3.697/exe/consense

echo "END STEP3: $(date)"
