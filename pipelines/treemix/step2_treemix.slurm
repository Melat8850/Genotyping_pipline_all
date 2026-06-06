#!/bin/bash
#SBATCH --job-name=treemix_step2
#SBATCH --account=nn10082k
#SBATCH --mem=8G
#SBATCH --time=1:00:00
#SBATCH --output=step2_%j.out
#SBATCH --error=step2_%j.err

module load  R/4.5.2-gfbf-2025b
Rscript step2_optM.R
