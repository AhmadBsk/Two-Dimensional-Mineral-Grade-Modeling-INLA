# 05_cross_validation.R
# Perform cross-validation for universal kriging and INLA+SPDE at various training fractions
# Saves results and summary tables

library(dplyr)
library(INLA)
source("code/03_kriging_universal.R")
source("code/04_inla_spde_model.R")
source("code/functions/helpers.R")

# Load cleaned data
data_df <- readRDS(file.path("data", "cleaned_data.rds"))

# Define training fractions and corresponding number of folds (k = 1/fraction)
# fractions: 0.05, 0.10, 0.20, 0.33, 0.50
fractions <- c(0.05, 0.10, 0.20, 0.33, 0.50)
k_values <- round(1 / fractions)  # 20, 10, 5, 3, 2

# We'll perform k-fold CV where each fold is used as training (size = 1/k)
# For each fraction, we run k-fold CV and collect predictions for all points.
# Then we compute MAE/RMSE/time and optionally save pointwise results.

# Initialize list to store summaries
summary_list <- list()

for (idx in seq_along(fractions)) {
  frac <- fractions[idx]
  k <- k_values[idx]
  cat(sprintf("\n=== Running CV for training fraction = %.2f (k=%d) ===\n", frac, k))
  
  # Randomly assign folds (ensuring each fold is roughly same size)
  n <- nrow(data_df)
  folds <- sample(rep(1:k, length.out = n))
  
  # Initialize results for this fraction
  inla_pred_all <- rep(NA, n)
  uk_pred_all <- rep(NA, n)
  
  # Timing
  start_time_inla <- Sys.time()
  start_time_uk <- Sys.time()
  
  # For INLA, we can reuse mesh across folds? Possibly yes if mesh based on all coordinates.
  # Build mesh once using all data coordinates to save time.
  all_coords <- as.matrix(data_df[, c("x", "y")])
  spde_obj <- build_spde(all_coords)
  mesh <- spde_obj$mesh
  spde <- spde_obj$spde
  
  # Cross-validation loop
  for (fold in 1:k) {
    train_idx <- which(folds == fold)
    test_idx <- which(folds != fold)
    
    train <- data_df[train_idx, ]
    test <- data_df[test_idx, ]
    
    # Universal Kriging
    uk_pred_log <- uk_predict(train, test)
    uk_pred_all[test_idx] <- uk_pred_log
    
    # INLA+SPDE
    inla_pred_log <- inla_spde_predict(train, test, mesh = mesh, spde = spde)
    inla_pred_all[test_idx] <- inla_pred_log
  }
  
  end_time_inla <- Sys.time()
  end_time_uk <- Sys.time()
  
  # Back-transform predictions
  inla_pred <- back_transform(inla_pred_all)
  uk_pred <- back_transform(uk_pred_all)
  observed <- data_df$Cu
  
  # Compute metrics
  MAE_inla <- mae(observed, inla_pred)
  RMSE_inla <- rmse(observed, inla_pred)
  time_inla <- as.numeric(difftime(end_time_inla, start_time_inla, units = "secs"))
  
  MAE_uk <- mae(observed, uk_pred)
  RMSE_uk <- rmse(observed, uk_pred)
  time_uk <- as.numeric(difftime(end_time_uk, start_time_uk, units = "secs"))
  
  # Store summary
  summary_list[[paste0("frac_", frac)]] <- data.frame(
    fraction = frac,
    method = c("INLA+SPDE", "UK"),
    MAE = round(c(MAE_inla, MAE_uk), 2),
    RMSE = round(c(RMSE_inla, RMSE_uk), 2),
    Time_sec = round(c(time_inla, time_uk), 2)
  )
  
  # Save pointwise predictions for this fraction (optional)
  results_df <- data.frame(
    x = data_df$x,
    y = data_df$y,
    observed = observed,
    inla_pred = inla_pred,
    uk_pred = uk_pred
  )
  write.csv(results_df, file = file.path("results", paste0("cv_results_", frac*100, "p.csv")), row.names = FALSE)
}

# Combine all summaries
summary_all <- do.call(rbind, summary_list)
print(summary_all)
write.csv(summary_all, file = file.path("results", "cv_summary.csv"), row.names = FALSE)

cat("\nCross-validation complete. Summary saved to results/cv_summary.csv\n")
