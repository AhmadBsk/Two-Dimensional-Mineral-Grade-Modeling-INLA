# 02_variogram_analysis.R
# Exploratory data analysis: trend analysis, histograms, variograms

library(ggplot2)
library(gstat)
library(sp)
library(cowplot)
library(readxl)

# Load cleaned data
data_df <- readRDS(file.path("data", "cleaned_data.rds"))

# ---- Trend Analysis ----
# Plot trends in x and y directions with polynomial fits
p_x <- ggplot(data_df, aes(x = x, y = logCu)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, aes(color = "Linear")) +
  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = FALSE, aes(color = "Quadratic")) +
  geom_smooth(method = "lm", formula = y ~ poly(x, 3), se = FALSE, aes(color = "Cubic")) +
  scale_color_manual(name = "Trend", values = c(Linear = "red", Quadratic = "blue", Cubic = "green4")) +
  labs(x = "Easting (m)", y = "log(Cu+1)", title = "Trend in Easting") +
  theme_minimal()

p_y <- ggplot(data_df, aes(x = y, y = logCu)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, aes(color = "Linear")) +
  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = FALSE, aes(color = "Quadratic")) +
  geom_smooth(method = "lm", formula = y ~ poly(x, 3), se = FALSE, aes(color = "Cubic")) +
  scale_color_manual(name = "Trend", values = c(Linear = "red", Quadratic = "blue", Cubic = "green4")) +
  labs(x = "Northing (m)", y = "log(Cu+1)", title = "Trend in Northing") +
  theme_minimal()

trend_plot <- plot_grid(p_x, p_y, ncol = 2)
ggsave(file.path("results", "figures", "trend_analysis.png"), trend_plot, width = 10, height = 5, dpi = 300)

# ---- Histograms ----
# Histogram of raw Cu and log-transformed Cu
h_raw <- ggplot(data_df, aes(x = Cu)) +
  geom_histogram(bins = 10, fill = "black", alpha = 0.5, color = 1) +
  labs(x = "Cu (ppm)", y = "Frequency", title = "Raw Data") +
  theme_minimal()

h_log <- ggplot(data_df, aes(x = logCu)) +
  geom_histogram(bins = 10, fill = "black", alpha = 0.5, color = 1) +
  labs(x = "log(Cu+1)", y = "Frequency", title = "Log-transformed") +
  theme_minimal()

hist_plot <- plot_grid(h_raw, h_log, ncol = 2)
ggsave(file.path("results", "figures", "histograms.png"), hist_plot, width = 8, height = 4, dpi = 300)

# ---- Detrending ----
# Fit linear trend model (first-order)
trend_model <- lm(logCu ~ x + y, data = data_df)
data_df$detrended <- residuals(trend_model)

# Convert to spatial object for variogram
coordinates(data_df) <- ~x+y

# ---- Directional Variogram ----
vgm_dir <- variogram(detrended ~ 1, data_df, alpha = c(0, 45, 90, 135))
# Fit a model (Matérn) to the omnidirectional (since isotropic assumed)
vgm_omni <- variogram(detrended ~ 1, data_df)
model_fit <- fit.variogram(vgm_omni, vgm("Mat"), fit.kappa = TRUE)

# Create a data frame of model values for plotting
max_dist <- max(vgm_omni$dist)
model_line <- variogramLine(model_fit, maxdist = max_dist)

p_vario <- ggplot() +
  geom_point(data = vgm_dir, aes(x = dist, y = gamma, shape = factor(dir.hor))) +
  geom_line(data = model_line, aes(x = dist, y = gamma), color = "red", size = 1) +
  labs(x = "Distance", y = "Semivariance", shape = "Direction") +
  ggtitle(paste0("Directional Variogram with Isotropic Model\nSill: ", round(model_fit$psill[2], 2),
                 ", Range: ", round(model_fit$range[2], 2),
                 ", Nugget: ", round(model_fit$psill[1], 2))) +
  theme_minimal()

ggsave(file.path("results", "figures", "variogram_directional.png"), p_vario, width = 7, height = 5, dpi = 300)

# Save model fit for later use (e.g., in kriging)
saveRDS(list(vgm_model = model_fit, trend_model = trend_model), file = file.path("data", "variogram_model.rds"))

cat("Variogram analysis complete. Figures saved.\n")
