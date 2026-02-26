# run_all.R
# Master script to run the entire analysis pipeline

cat("Starting analysis pipeline...\n")

# Step 1: Preprocessing
cat("\n=== Step 1: Preprocessing ===\n")
source("code/01_preprocessing.R")

# Step 2: Variogram analysis and EDA
cat("\n=== Step 2: Variogram analysis ===\n")
source("code/02_variogram_analysis.R")

# Step 3: Cross-validation (this may take a while)
cat("\n=== Step 3: Cross-validation ===\n")
source("code/05_cross_validation.R")

# Step 4: Anomaly detection (for 20% fraction as example)
cat("\n=== Step 4: Anomaly detection ===\n")
source("code/06_anomaly_detection.R")

# Step 5: Generate final tables and figures
cat("\n=== Step 5: Final tables and figures ===\n")
source("code/07_figures_tables.R")

cat("\nAll done!\n")
