# 03_kriging_universal.R
# Functions for universal kriging (UK) prediction

library(gstat)
library(sp)
library(automap)

#' Universal kriging prediction for a given training and test set
#' @param train Data frame with columns x, y, logCu (log-transformed response)
#' @param test Data frame with columns x, y (coordinates to predict)
#' @return Vector of predictions on log scale (can be back-transformed later)
uk_predict <- function(train, test) {
  coordinates(train) <- ~x+y
  coordinates(test) <- ~x+y
  
  # Use autoKrige for simplicity; in practice you might use a pre-fitted variogram
  # Here we let automap fit variogram each time (for cross-validation)
  krig_result <- tryCatch(
    autoKrige(logCu ~ x + y, train, test),
    error = function(e) NULL
  )
  
  if (is.null(krig_result)) {
    # Fallback: mean of training
    return(rep(mean(train$logCu), nrow(test)))
  } else {
    return(krig_result$krige_output$var1.pred)
  }
}
