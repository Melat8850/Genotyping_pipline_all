## Lostruct scan script
rm(list = ls())
.libPaths("/cluster/home/melatag/R/x86_64-pc-linux-gnu-library/4.5")
suppressPackageStartupMessages(library(lostruct))
suppressPackageStartupMessages(library(getopt))
library(dplyr)

# specify command line options
spec <- matrix(c(
  'vcf',     'v', 1, 'character', 'Path to vcf',
  'cluster', 'k', 1, 'numeric',   'number of k clusters',
  'window',  'w', 1, 'numeric',   'Window size for analysis',
  'cores',   'c', 1, 'numeric',   'number of cores for parallel',
  'samples', 's', 1, 'character', 'path to sample file',
  'out',     'o', 1, 'character', 'specify output path'
), ncol = 5, byrow = TRUE)

# set command line options
opt <- getopt(spec)

# show help if asked for
if (!is.null(opt$help)) {
  cat(paste(getopt(spec, usage = TRUE), "\n"))
  q()
}

# set variables for call
vcf_path    <- opt$vcf
k_cluster   <- opt$cluster
window_size <- opt$window
cores       <- opt$cores
sample_path <- opt$samples
out_path    <- opt$out

# read in sample file
my_samples <- scan(sample_path, what = "character")
message(sprintf("Sample file read in from %s", sample_path))

# read in data - use vcf_windower
snps <- vcf_windower(vcf_path, size = window_size, type = "snp", samples = my_samples)
message("vcf windows read in")

# extract regions
regions <- region(snps)()
message(sprintf("There are %s windows of %s length", nrow(regions), window_size))
message(sprintf("Calculating eigenwindows with %s clusters on %s cores", k_cluster, cores))

# with windowed method
pcs <- eigen_windows(snps, k = k_cluster, mc.cores = cores)
message("Now creating PC distance matrix")

# create distance matrix — pairwise distance matrix for MDS analysis
pcdist <- pc_dist(pcs, npc = k_cluster)

# write out data
write.csv(regions,              paste0(out_path, "_regions.csv"), row.names = FALSE)
write.csv(as.data.frame(pcs),   paste0(out_path, "_pcs.csv"),    row.names = FALSE)
write.csv(as.data.frame(pcdist),paste0(out_path, "_pcdist.csv"), row.names = FALSE)

message("Finally fitting MDS")

# perform a 2D MDS
fit2d <- cmdscale(pcdist, eig = TRUE, k = k_cluster)
saveRDS(fit2d, paste0(out_path, "_fit2d.RDS"))

message("Done!")
