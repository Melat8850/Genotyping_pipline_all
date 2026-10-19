#!/bin/bash
#SBATCH --job-name=fsc_model2_geneflow
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --output=model4_ghost_%j.out
#SBATCH --error=model4_ghost_%j.err

FSC28=/cluster/work/users/melatag/software/fastsimcoal2/fsc28_linux64/fsc28

$FSC28 \
  -t model4_ghost.tpl \
  -e model4_ghost.est \
  -n 100000 \
  -N 100000 \
  -m \
  -M 0.001 \
  -l 10 \
  -L 40 \
  -c 1 \
  -q

