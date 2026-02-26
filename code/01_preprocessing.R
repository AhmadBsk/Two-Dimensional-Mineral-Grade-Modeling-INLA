# 01_preprocessing.R
# Data loading, cleaning, outlier removal, and transformation

library(readxl)
library(dplyr)
library(gstat)
library(sp)

# Set seed for reproducibility
set.seed(123)

# Load data (assumes data file is in "data/" folder relative to project root)
data_path <- file.path("data", "keror2-2.xlsx")
data_raw <- read_xlsx(data_path, sheet = "Sheet1")

# Convert all columns to numeric
data_num <- as.data.frame(apply(data_raw, 2, as.numeric))

# Select relevant columns: x, y, Cu
data <- data_num[, c(2, 3, which(names(data_num) == "Cu"))]
names(data) <- c("x", "y", "Cu")

# Remove duplicate observations based on coordinates
data <- data[!duplicated(data[, c("x", "y")]), ]

# Log-transform Cu (for modeling)
data$logCu <- log(data$Cu + 1)

# ---- Outlier detection using LOOCV kriging ----
# Perform leave-one-out cross-validation with universal kriging to identify outliers
coordinates(data) <- ~x+y

# Initialize vector for LOOCV predictions
n <- nrow(data)
predictions <- rep(NA, n)

for (i in 1:n) {
  train <- data[-i, ]
  test <- data[i, ]
  
  # Fit variogram automatically and krige
  # Using automap for simplicity; may need manual variogram fitting in practice
  krig_model <- tryCatch(
    autoKrige(logCu ~ x + y, train, test),
    error = function(e) NULL
  )
  
  if (!is.null(krig_model)) {
    predictions[i] <- krig_model$krige_output$var1.pred
  } else {
    # If autoKrige fails, use simple mean as fallback
    predictions[i] <- mean(train$logCu)
  }
}

# Back-transform predictions
pred_Cu <- exp(predictions) - 1

# Calculate absolute differences
data$pred_LOOCV <- pred_Cu
data$diff <- abs(data$Cu - data$pred_LOOCV)

# Identify outliers: points with largest differences (e.g., top 2)
outlier_indices <- order(data$diff, decreasing = TRUE)[1:2]
cat("Identified outliers at indices:", outlier_indices, "\n")
print(data[outlier_indices, c("x", "y", "Cu", "pred_LOOCV", "diff")])

# Replace outliers with a reasonable value (e.g., 6000 ppm as per paper)
data$Cu[outlier_indices] <- 6000
# Recompute logCu after replacement
data$logCu <- log(data$Cu + 1)

# Remove the temporary columns
data$pred_LOOCV <- NULL
data$diff <- NULL

# Convert back to data frame for later use
data_df <- as.data.frame(data)
data_df <- data_df[, c("x", "y", "Cu", "logCu")]

# Save cleaned data
saveRDS(data_df, file = file.path("data", "cleaned_data.rds"))
write.csv(data_df, file = file.path("data", "cleaned_data.csv"), row.names = FALSE)

cat("Preprocessing complete. Cleaned data saved to data/cleaned_data.rds\n")
