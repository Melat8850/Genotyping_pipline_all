#!/bin/bash
#SBATCH --job-name=GONE2_ZAF_CI
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-20
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=GONE2_ZAF_CI_%A_%a.out
#SBATCH --error=GONE2_ZAF_CI_%A_%a.err

set -e

BASE=/cluster/work/users/melatag/genotyping_pipeline/output/GONE/software/GONE2
WORK=${BASE}/ZAF_CI/replicates

cd "$WORK"

ulimit -s unlimited

REP=$(printf "%02d" "$SLURM_ARRAY_TASK_ID")

echo "Starting ZAF replicate ${REP}"

shuf -n 2000000 ${BASE}/ZAF_GONE_final.map \
    | cut -f2 > ZAF_rep${REP}_snps.txt

plink \
    --file ${BASE}/ZAF_GONE_final \
    --extract ZAF_rep${REP}_snps.txt \
    --allow-extra-chr \
    --chr-set 30 \
    --recode \
    --out ZAF_rep${REP}

wc -l ZAF_rep${REP}.map

${BASE}/gone2 \
    -r 1 \
    -t 1 \
    -o ZAF_rep${REP}_GONE2 \
    ZAF_rep${REP}.ped

echo "Finished ZAF replicate ${REP}"
