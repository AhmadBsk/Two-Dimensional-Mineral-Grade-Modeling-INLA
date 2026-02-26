# 04_inla_spde_model.R
# Functions for INLA+SPDE modeling

library(INLA)
library(sp)

#' Build SPDE mesh and model for given data
#' @param coords Matrix of coordinates (x,y)
#' @param max.edge Multiplier for mesh edge length (default max(dist)/25 as in user code)
#' @param offset.outer Outer offset multiplier (default max(dist)/20)
#' @return List with mesh and SPDE model object
build_spde <- function(coords, max.edge.factor = 25, offset.outer.factor = 20) {
  max_dist <- max(dist(coords))
  max.edge <- c(max_dist / max.edge.factor)
  bound.outer <- c(max_dist / offset.outer.factor)
  
  mesh <- inla.mesh.2d(loc = coords, max.edge = max.edge, offset = c(max.edge, bound.outer))
  
  # Prior settings (adjust based on domain knowledge)
  prior.range <- c(500, 0.1)   # P(range < 500) = 0.1
  prior.sigma <- c(0.5, 0.01)  # P(sigma > 0.5) = 0.01
  
  spde <- inla.spde2.pcmatern(mesh, alpha = 1.5,
                               prior.range = prior.range,
                               prior.sigma = prior.sigma)
  
  list(mesh = mesh, spde = spde, prior.range = prior.range, prior.sigma = prior.sigma)
}

#' Fit INLA+SPDE model and predict at new locations
#' @param train Data frame with columns x, y, logCu
#' @param test Data frame with columns x, y
#' @param mesh SPDE mesh object (if NULL, will build from train)
#' @param spde SPDE model object (if NULL, will build from train)
#' @return Vector of predicted means (log scale)
inla_spde_predict <- function(train, test, mesh = NULL, spde = NULL) {
  # Prepare coordinates
  coords_train <- as.matrix(train[, c("x", "y")])
  coords_test <- as.matrix(test[, c("x", "y")])
  
  if (is.null(mesh) || is.null(spde)) {
    # Build mesh and SPDE from training data
    spde_obj <- build_spde(coords_train)
    mesh <- spde_obj$mesh
    spde <- spde_obj$spde
  }
  
  # Create indices for SPDE effects
  indexs <- inla.spde.make.index("s", n.spde = spde$n.spde)
  
  # Projection matrices
  A_train <- inla.spde.make.A(mesh, loc = coords_train)
  A_test <- inla.spde.make.A(mesh, loc = coords_test)
  
  # Stack for estimation
  stk.e <- inla.stack(
    tag = "est",
    data = list(y = train$logCu),
    A = list(1, A_train),
    effects = list(data.frame(b0 = rep(1, nrow(train))), s = indexs)
  )
  
  # Stack for prediction
  stk.p <- inla.stack(
    tag = "pred",
    data = list(y = NA),
    A = list(1, A_test),
    effects = list(data.frame(b0 = rep(1, nrow(test))), s = indexs)
  )
  
  stk.full <- inla.stack(stk.e, stk.p)
  
  formula <- y ~ -1 + b0 + f(s, model = spde)
  
  # Run INLA
  res <- inla(formula,
              data = inla.stack.data(stk.full),
              control.predictor = list(A = inla.stack.A(stk.full), compute = TRUE),
              control.compute = list(config = TRUE),  # for posterior sampling if needed
              verbose = FALSE)
  
  # Extract predictions
  index_pred <- inla.stack.index(stk.full, tag = "pred")$data
  pred_mean <- res$summary.fitted.values[index_pred, "mean"]
  
  return(pred_mean)
}
