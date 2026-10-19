#!/bin/bash
#SBATCH --job-name=fsc_model3_admix
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --output=fsc_model3_admix_%j.out
#SBATCH --error=fsc_model3_admix_%j.err

set -e

cd /cluster/work/users/melatag/genotyping_pipeline/output/fastsimcoal2/sfs_easysfs_test/model3_admixture

FSC28=/cluster/work/users/melatag/software/fastsimcoal2/fsc28_linux64/fsc28

$FSC28 \
    -t model3_admixture.tpl \
    -e model3_admixture.est \
    -E 100 \
    -m \
    -0 \
    -C 10 \
    -n 100000 \
    -L 40 \
    -M \
    -c 1 \
    -q
