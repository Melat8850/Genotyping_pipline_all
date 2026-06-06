########################################
# 1. LOAD DATA
########################################

rm(list = ls())

data <- read.csv("/cluster/work/users/melatag/genotyping_pipeline/output/genome_scan/nf_pipeline/work/63/12e523ab2f1284e62884c7fa22da2e/variants_default_filters.csv",
                 header=TRUE)
########################################
# 2. DEFINE POPULATIONS
########################################

africa_pops <- c("Gambia","Senegal","South_Africa","Kenya","Madagascar","Cabo_Verde")
asia_pop <- "India"
europe_pop <- "Norway"

########################################
# 3. CALCULATE PI THRESHOLDS (STRICT)
########################################

pi_thresholds <- sapply(c(africa_pops, asia_pop, europe_pop), function(pop) {
  quantile(data[[paste0("pi_", pop)]], 0.01, na.rm=TRUE)  # 1% = strong selection
})

save(pi_thresholds, file="pi_thresholds.RData")

########################################
# 4. IDENTIFY LOW PI REGIONS (AFRICA)
########################################

low_africa_matrix <- sapply(africa_pops, function(pop) {
  data[[paste0("pi_", pop)]] < pi_thresholds[pop]
})

low_africa_count <- rowSums(low_africa_matrix)

low_pi_regions <- data[low_africa_count >= 4, ]  # strict

cat("Low pi regions:", nrow(low_pi_regions), "\n")

########################################
# 5. CALCULATE FST & DXY THRESHOLDS
########################################

fst_cols_asia <- paste0("Fst_", africa_pops, "_", asia_pop)
dxy_cols_asia <- paste0("dxy_", africa_pops, "_", asia_pop)

fst_cols_eu <- paste0("Fst_", africa_pops, "_", europe_pop)
dxy_cols_eu <- paste0("dxy_", africa_pops, "_", europe_pop)

fst_thresholds_asia <- sapply(fst_cols_asia, function(col) {
  quantile(data[[col]], 0.99, na.rm=TRUE)
})

dxy_thresholds_asia <- sapply(dxy_cols_asia, function(col) {
  quantile(data[[col]], 0.99, na.rm=TRUE)
})

fst_thresholds_eu <- sapply(fst_cols_eu, function(col) {
  quantile(data[[col]], 0.99, na.rm=TRUE)
})

dxy_thresholds_eu <- sapply(dxy_cols_eu, function(col) {
  quantile(data[[col]], 0.99, na.rm=TRUE)
})

########################################
# 6. FILTER BY FST + DXY
########################################

candidate_regions <- low_pi_regions

fst_high_asia <- rowSums(sapply(seq_along(africa_pops), function(i) {
  col <- fst_cols_asia[i]
  candidate_regions[[col]] > fst_thresholds_asia[i]
}))

dxy_high_asia <- rowSums(sapply(seq_along(africa_pops), function(i) {
  col <- dxy_cols_asia[i]
  candidate_regions[[col]] > dxy_thresholds_asia[i]
}))

fst_high_eu <- rowSums(sapply(seq_along(africa_pops), function(i) {
  col <- fst_cols_eu[i]
  candidate_regions[[col]] > fst_thresholds_eu[i]
}))

dxy_high_eu <- rowSums(sapply(seq_along(africa_pops), function(i) {
  col <- dxy_cols_eu[i]
  candidate_regions[[col]] > dxy_thresholds_eu[i]
}))

candidate_regions <- candidate_regions[
  fst_high_asia >= 4 &
  dxy_high_asia >= 4 &
  fst_high_eu >= 4 &
  dxy_high_eu >= 4,
]

cat("Final candidate regions:", nrow(candidate_regions), "\n")

########################################
# 7. SAVE RESULTS
########################################

write.csv(candidate_regions, "candidate_regions.csv", row.names=FALSE)

########################################
# 8. PLOTTING (SAVE TO FILES)
########################################

dir.create("plots", showWarnings=FALSE)

for(pop in c(africa_pops, asia_pop, europe_pop)){
  
  pi_col <- paste0("pi_", pop)
  
  png(paste0("plots/pi_", pop, ".png"), width=1400, height=600)
  
  plot(data$mid, data[[pi_col]],
       pch=19, cex=0.3,
       col="grey",
       main=paste("Pi -", pop),
       xlab="Genomic position",
       ylab="Pi")
  
  if(nrow(candidate_regions) > 0){
    points(candidate_regions$mid,
           candidate_regions[[pi_col]],
           col="red", pch=19)
  }
  
  dev.off()
}

########################################
# 9. OPTIONAL: FST PLOTS (EXAMPLE)
########################################

for(pop in africa_pops){
  
  fst_col <- paste0("Fst_", pop, "_", asia_pop)
  
  png(paste0("plots/Fst_", pop, "_India.png"), width=1400, height=600)
  
  plot(data$mid, data[[fst_col]],
       pch=19, cex=0.3,
       col="grey",
       main=fst_col,
       xlab="Genomic position",
       ylab="FST")
  
  if(nrow(candidate_regions) > 0){
    points(candidate_regions$mid,
           candidate_regions[[fst_col]],
           col="red", pch=19)
  }
  
  dev.off()
}

########################################
# DONE
########################################

cat("Pipeline complete.\n")
