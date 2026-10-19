#!/bin/bash
#SBATCH --job-name=GONE2_POP
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=GONE2_%x_%j.out
#SBATCH --error=GONE2_%x_%j.err

set -e

BASE=/cluster/work/users/melatag/genotyping_pipeline/output/GONE/software/GONE2
POP=$1
WORK=${BASE}/${POP}

if [ -z "$POP" ]; then
    echo "ERROR: population not specified"
    echo "Use: sbatch run_GONE2_Africa.sh CPV"
    exit 1
fi

mkdir -p "$WORK"
cd "$WORK"

module purge
module load BCFtools/1.22-GCC-14.3.0
module load PLINK/1.9b_6.13-x86_64

ulimit -s unlimited

echo "======================================"
echo "Population: $POP"
echo "Job: $SLURM_JOB_ID"
echo "Start: $(date)"
echo "======================================"

# ==========================================================
# STEP 1-4: Use existing files if already present
# ==========================================================

if [ -f "${POP}_GONE.ped" ] && [ -f "${POP}_GONE.map" ]; then

    echo "Existing ${POP}_GONE.ped/.map found."
    echo "Skipping VCF extraction and PLINK preparation."

else

    echo "Preparing ${POP} from VCF..."

    bcftools view \
        -S ${BASE}/${POP}_samples.txt \
        -Oz \
        -o ${POP}_only.vcf.gz \
        ${BASE}/variants_default_filters.vcf.gz

    tabix -f -p vcf ${POP}_only.vcf.gz

    bcftools view \
        -c 1 \
        -Oz \
        -o ${POP}_polymorphic.vcf.gz \
        ${POP}_only.vcf.gz

    tabix -f -p vcf ${POP}_polymorphic.vcf.gz

    bcftools view \
        -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr1A \
        -Oz \
        -o ${POP}_chr_only.vcf.gz \
        ${POP}_polymorphic.vcf.gz

    tabix -f -p vcf ${POP}_chr_only.vcf.gz

    plink \
        --vcf ${POP}_chr_only.vcf.gz \
        --allow-extra-chr \
        --chr-set 30 \
        --double-id \
        --recode \
        --out ${POP}_GONE

fi


# ==========================================================
# STEP 5: FIX SNP IDs
# ==========================================================

echo "======================================"
echo "Creating unique SNP IDs"
echo "======================================"

awk 'BEGIN{OFS="\t"} {$2="SNP_"$1"_"$4; print}' \
    ${POP}_GONE.map \
    > ${POP}_GONE_named.map

cp ${POP}_GONE.ped ${POP}_GONE_named.ped

TOTAL=$(wc -l < ${POP}_GONE_named.map)
UNIQUE=$(cut -f2 ${POP}_GONE_named.map | sort -u | wc -l)

echo "Total SNPs: $TOTAL"
echo "Unique SNP IDs: $UNIQUE"

if [ "$TOTAL" -ne "$UNIQUE" ]; then
    echo "ERROR: SNP IDs are not unique."
    exit 1
fi


# ==========================================================
# STEP 6: RANDOMLY SELECT 2 MILLION SNPs
# ==========================================================

echo "======================================"
echo "Selecting SNPs"
echo "======================================"

if [ "$TOTAL" -gt 2000000 ]; then

    shuf -n 2000000 ${POP}_GONE_named.map |
        cut -f2 > subset_2M.txt

else

    cut -f2 ${POP}_GONE_named.map > subset_2M.txt

fi

SELECTED=$(sort -u subset_2M.txt | wc -l)

echo "Selected SNPs: $SELECTED"


# ==========================================================
# STEP 7: CREATE FINAL DATASET
# ==========================================================

echo "======================================"
echo "Creating ${POP}_2M dataset"
echo "======================================"

rm -f ${POP}_2M.ped ${POP}_2M.map

plink \
    --file ${POP}_GONE_named \
    --extract subset_2M.txt \
    --allow-extra-chr \
    --chr-set 30 \
    --recode \
    --out ${POP}_2M


# ==========================================================
# STEP 8: CHECK SNP NUMBER
# ==========================================================

FINAL=$(wc -l < ${POP}_2M.map)

echo "Expected SNPs: $SELECTED"
echo "Actual SNPs:   $FINAL"

if [ "$FINAL" -ne "$SELECTED" ]; then
    echo "ERROR: SNP selection failed."
    exit 1
fi

echo "SNP selection PASSED."

ls -lh ${POP}_2M.ped ${POP}_2M.map


# ==========================================================
# STEP 9: RUN GONE2
# ==========================================================

echo "======================================"
echo "Starting GONE2"
echo "======================================"

${BASE}/gone2 \
    -r 1 \
    -t 1 \
    -o ${POP}_GONE2_final \
    ${POP}_2M.ped

echo "======================================"
echo "${POP} GONE2 FINISHED"
echo "End: $(date)"
echo "======================================"

ls -lh \
    ${POP}_GONE2_final_GONE2_Ne \
    ${POP}_GONE2_final_GONE2_d2 \
    ${POP}_GONE2_final_GONE2_STATS
