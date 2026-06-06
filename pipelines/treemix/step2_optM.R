library(data.table)
library(OptM)
library(plyr)

folder <- "/cluster/work/users/melatag/genotyping_pipeline/output/treemix/TreeMix/test_migrations"

# Linear method
test.linear = optM(folder, method = "linear", tsv="linear.txt")
pdf("optM_linear.pdf")
plot_optM(test.linear, method = "linear")
dev.off()

# Evanno method
test.optM = optM(folder, tsv="Evanno.variance.txt")
pdf("optM_evanno.pdf")
plot_optM(test.optM, method = "Evanno")
dev.off()

print(test.linear$out)
