# 06_anomaly_detection.R
# Detect anomalies using probability plots on CV predictions for each fraction

library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)
source("code/functions/helpers.R")

# Load CV results for a given fraction (e.g., 20%)
frac <- 0.20
results_file <- file.path("results", paste0("cv_results_", frac*100, "p.csv"))
results <- read.csv(results_file)

# Compute CDFs and detect anomalies for observed, UK, INLA
cdf_obs <- detect_anomalies_cdf(results$observed)
cdf_uk <- detect_anomalies_cdf(results$uk_pred)
cdf_inla <- detect_anomalies_cdf(results$inla_pred)

# Function to plot enhanced CDF
plot_cdf <- function(cdf_list, method_name) {
  df <- cdf_list$cdf_data
  threshold <- cdf_list$threshold
  text_x <- min(df$value) + 0.3 * diff(range(df$value))
  
  p <- ggplot(df, aes(x = value, y = cdf)) +
    geom_point(data = subset(df, !is_anomaly), aes(color = "Normal"), shape = 1, size = 3) +
    geom_point(data = subset(df, is_anomaly), aes(color = "Anomaly"), shape = 16, size = 4) +
    geom_smooth(aes(y = predicted), method = "lm", se = FALSE, linetype = "dashed", color = "blue", size = 1) +
    geom_line(color = "red", alpha = 0.7, size = 0.8) +
    scale_color_manual(values = c("Normal" = "gray", "Anomaly" = "black")) +
    labs(x = "Value", y = "Cumulative Probability (%)", title = paste("CDF -", method_name)) +
    theme_minimal() +
    theme(legend.position = "none")
  
  if (!is.na(threshold)) {
    p <- p + annotate("text", x = text_x, y = 15, 
                      label = paste("Threshold:", round(threshold)), 
                      hjust = 0, vjust = 1, size = 4, fontface = "bold")
  } else {
    p <- p + annotate("text", x = text_x, y = 15, label = "No anomalies", 
                      hjust = 0, vjust = 1, size = 4, fontface = "bold")
  }
  
  p + coord_cartesian(ylim = c(0, 100))
}

p_obs <- plot_cdf(cdf_obs, "Observed")
p_uk <- plot_cdf(cdf_uk, "UK")
p_inla <- plot_cdf(cdf_inla, "INLA+SPDE")

# Arrange plots
final_plot <- grid.arrange(p_uk, p_inla, nrow = 1)
ggsave(file.path("results", "figures", paste0("anomaly_cdf_", frac*100, "p.png")), final_plot,
       width = 10, height = 5, dpi = 600)

# Identify anomaly points
threshold_obs <- cdf_obs$threshold
threshold_uk <- cdf_uk$threshold
threshold_inla <- cdf_inla$threshold

# Function to get anomaly coordinates
get_anomaly_points <- function(data, values, threshold, method_name) {
  if (is.na(threshold)) return(data.frame(x = numeric(0), y = numeric(0), type = character(0)))
  idx <- which(values >= threshold)
  data.frame(x = data$x[idx], y = data$y[idx], type = method_name)
}

anom_obs <- get_anomaly_points(results, results$observed, threshold_obs, "Raw anomaly")
anom_uk <- get_anomaly_points(results, results$uk_pred, threshold_uk, "UK anomaly")
anom_inla <- get_anomaly_points(results, results$inla_pred, threshold_inla, "INLA+SPDE anomaly")

# Find common anomalies
common_raw_uk <- inner_join(anom_obs, anom_uk, by = c("x", "y")) %>% select(x, y) %>% mutate(type = "Raw & UK")
common_raw_inla <- inner_join(anom_obs, anom_inla, by = c("x", "y")) %>% select(x, y) %>% mutate(type = "Raw & INLA+SPDE")
common_all <- inner_join(common_raw_uk, anom_inla, by = c("x", "y")) %>% select(x, y) %>% mutate(type = "Raw, UK & INLA+SPDE")

# Combine all anomaly points for plotting
anom_all <- bind_rows(
  anom_obs, anom_uk, anom_inla,
  common_raw_uk, common_raw_inla, common_all
)

# Add counts to labels
counts <- anom_all %>% group_by(type) %>% summarise(n = n())
facet_labels <- setNames(
  paste0(counts$type, ": ", counts$n, " (", round(counts$n / nrow(results) * 100, 1), "%)"),
  counts$type
)

anom_all$type <- factor(anom_all$type, levels = names(facet_labels))

# Plot anomaly locations
p_anom_map <- ggplot(anom_all, aes(x = x, y = y)) +
  geom_point(aes(shape = type), size = 3, color = "black") +
  scale_shape_manual(values = c(
    "Raw anomaly" = 1,
    "UK anomaly" = 2,
    "INLA+SPDE anomaly" = 3,
    "Raw & UK" = 4,
    "Raw & INLA+SPDE" = 5,
    "Raw, UK & INLA+SPDE" = 15
  ), labels = facet_labels) +
  facet_wrap(~type, nrow = 2, ncol = 3, labeller = labeller(type = facet_labels)) +
  coord_fixed(xlim = range(results$x) + c(-50, 50), ylim = range(results$y) + c(-50, 50)) +
  labs(x = "X", y = "Y") +
  theme_bw(base_size = 12) +
  theme(legend.position = "none",
        strip.text = element_text(size = 10, face = "bold"),
        axis.text.x = element_text(angle = 90, hjust = 1))

ggsave(file.path("results", "figures", paste0("anomaly_map_", frac*100, "p.png")), p_anom_map,
       width = 29.7, height = 21, units = "cm", dpi = 600)

cat("Anomaly detection complete. Figures saved.\n")
