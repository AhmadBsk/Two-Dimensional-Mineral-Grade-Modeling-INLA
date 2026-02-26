# 07_figures_tables.R
# Generate all figures and tables for the paper

source("code/02_variogram_analysis.R")   # already produces figures
source("code/05_cross_validation.R")      # produces summary table
source("code/06_anomaly_detection.R")     # produces anomaly figures for a chosen fraction

# Additionally, we can create the combined table (Table 3 from paper) using cv_summary.csv
cv_summary <- read.csv(file.path("results", "cv_summary.csv"))

# Reshape to have methods as columns and fractions as rows
library(tidyr)
table3 <- cv_summary %>%
  pivot_wider(id_cols = fraction, names_from = method, values_from = c(MAE, RMSE, Time_sec)) %>%
  arrange(fraction)

# Write to CSV for LaTeX or Word
write.csv(table3, file.path("results", "tables", "table3_comparison.csv"), row.names = FALSE)

cat("All figures and tables generated.\n")
