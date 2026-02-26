# helpers.R
# Helper functions for geostatistical modeling and evaluation

#' Calculate Mean Absolute Error (MAE)
#' @param observed Vector of observed values
#' @param predicted Vector of predicted values
#' @return MAE value
mae <- function(observed, predicted) {
  mean(abs(observed - predicted), na.rm = TRUE)
}

#' Calculate Root Mean Square Error (RMSE)
#' @param observed Vector of observed values
#' @param predicted Vector of predicted values
#' @return RMSE value
rmse <- function(observed, predicted) {
  sqrt(mean((observed - predicted)^2, na.rm = TRUE))
}

#' Back-transform log-transformed copper grades (log(Cu+1))
#' @param log_values Vector of log-transformed values
#' @return Back-transformed values (original scale)
back_transform <- function(log_values) {
  exp(log_values) - 1
}

#' Forward transform copper grades to log scale
#' @param values Vector of copper grades (ppm)
#' @return Log-transformed values log(Cu+1)
log_transform <- function(values) {
  log(values + 1)
}

#' Compute CDF and identify anomalies using probability plot method
#' @param data Vector of values
#' @param threshold_pct Percentile threshold for anomaly detection (default 95)
#' @return List with CDF data, threshold, and anomaly indices
detect_anomalies_cdf <- function(data, threshold_pct = 95) {
  ecdf_fun <- ecdf(data)
  sorted <- sort(unique(data))
  cdf_vals <- ecdf_fun(sorted) * 100
  df <- data.frame(value = sorted, cdf = cdf_vals)
  
  # Fit linear model to CDF (assuming normal background)
  model <- lm(cdf ~ value, data = df)
  df$predicted <- predict(model, newdata = df)
  
  # Identify anomalies where observed CDF < predicted and value > median
  median_val <- median(data)
  df$is_anomaly <- df$cdf < df$predicted & df$value >= median_val
  
  # Threshold is the minimum value among anomalies (if any)
  threshold <- ifelse(any(df$is_anomaly), min(df$value[df$is_anomaly]), NA)
  
  list(
    cdf_data = df,
    threshold = threshold,
    anomaly_indices = which(data %in% df$value[df$is_anomaly])
  )
}
