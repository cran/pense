% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/elnet.R
\name{elnet}
\alias{elnet}
\title{Elastic Net Estimator for Regression}
\usage{
elnet(x, y, alpha, nlambda = 100, lambda, weights, intercept = TRUE,
  options = en_options_aug_lars(), lambda_min_ratio, xtest,
  correction = TRUE)
}
\arguments{
\item{x}{data matrix with predictors}

\item{y}{response vector}

\item{alpha}{controls the balance between the L1 and the L2 penalty.
\code{alpha = 0} is the ridge (L2) penalty, \code{alpha = 1} is
the lasso.}

\item{nlambda}{size of the lambda grid if \code{lambda} is not specified.}

\item{lambda}{a grid of decreasing lambda values.}

\item{weights}{an optional vector of weights to be used in the fitting
process. Should be \code{NULL} or a numeric vector. If non-NULL,
weighted EN is used with weights \code{weights}. See also 'Details'.}

\item{intercept}{should an intercept be estimated?}

\item{options}{additional options for the EN algorithm. See
\code{\link{en_options}} for details.}

\item{lambda_min_ratio}{if the lambda grid should be automatically defined,
the ratio of the smallest to the largest lambda value in the grid. The
default is \code{1e-6} if $n < p$, and
\code{1e-5 * 10^floor(log10(p / n))} otherwise.}

\item{xtest}{data matrix with predictors used for prediction. This is useful
for testing the prediction performance on an independent test set.}

\item{correction}{should the "corrected" EN estimator be returned.
If \code{TRUE}, as by default, the corrected estimator as defined in
Zou & Hastie (2005) is returned.}
}
\value{
\item{lambda}{vector of lambda values.}
 \item{status}{integer specifying the exit status of the EN algorithm.}
 \item{message}{explanation of the exit status.}
 \item{coefficients}{matrix of regression coefficients. Each
     column corresponds to the estimate for the lambda value at the same
     index.}
 \item{residuals}{matrix of residuals. Each column corresponds to the
     residuals for the lambda value at the same index.}
 \item{predictions}{if \code{xtest} was given, matrix of predicted values.
     Each column corresponds to the predictions for the lambda value at the
     same index.}
}
\description{
Estimate the elastic net regression coefficients.
}
\details{
This solves the minimization problem
\deqn{\frac{1}{2 N} RSS + \lambda \left(
        \frac{(1 - \alpha)} {2} \| \beta \|_2^2 + \alpha \| \beta \|_1
 \right)}{
     (1/2N) RSS + \lambda * (
         (1 - \alpha) / 2 * L2(\beta)^2 + \alpha * L1(\beta)
 )}

If weights are supplied, the minimization problem becomes
\deqn{\frac{1}{2 N} \sum_{i = 1}^n w_i r_i^2 + \lambda \left(
        \frac{(1 - \alpha)} {2} \| \beta \|_2^2 + \alpha \| \beta \|_1
  \right)}{
     (1/2N) \sum(w * (y - r^2)) + \lambda * (
         (1 - \alpha) / 2 * L2(\beta)^2 + \alpha * L1(\beta)
  )}
}
\section{Algorithms}{

Currently this function can compute the elastic net estimator using either
augmented LARS or the Dual Augmented Lagrangian (DAL) algorithm
(Tomioka 2011).
Augmented LARS performs LASSO via the LARS algorithm (or OLS if
\code{alpha = 0}) on the data matrix augmented with the L2 penalty term.
The time complexity of this algorithm increases fast with an increasing
number of predictors. The algorithm currently can not leverage a previous or
an approximate solution to speed up computations. However, it is always
guaranteed to find the solution.

DAL is an iterative algorithm directly minimizing the Elastic Net objective.
The algorithm can take an approximate solution to the problem to speed
up convergence. In the case of very small lambda values and a bad starting
point, DAL may not converge to the solution and hence give wrong
results. This would be indicated in the returned status code. Time complexity
of this algorithm is dominated by the number of observations.

DAL is much faster for a small number of observations (< 200) and a large
number of predictors, especially if an approximate solution is available.
}

\examples{
# Generate some dummy data
set.seed(12345)
n <- 30
p <- 15
x <- 1 + matrix(rnorm(n * p), ncol = p)
y <- x \%*\% c(2:5, numeric(p - 4)) + rnorm(n)

x_test <- matrix(rnorm(10 * n * p), ncol = p)
y_test <- drop(x_test \%*\% c(2:5, numeric(p - 4)) + rnorm(n))

# Compute the classical EN with predictions for x_test
set.seed(1234)
est <- elnet(
    x, y,
    alpha = 0.6,
    nlambda = 100,
    xtest = x_test
)

# Plot the RMSPE computed from the given test set
rmspe_test <- sqrt(colMeans((y_test - est$predictions)^2))
plot(est$lambda, rmspe_test, log = "x")

##
## For large data sets, the DAL algorithm is much faster
##
set.seed(12345)
n <- 100
p <- 1500
x <- 1 + matrix(rnorm(n * p), ncol = p)
y <- x \%*\% c(2:5, numeric(p - 4)) + rnorm(n)

x_test <- matrix(rnorm(10 * n * p), ncol = p)
y_test <- drop(x_test \%*\% c(2:5, numeric(p - 4)) + rnorm(n))

# The DAL algorithm takes ~1.5 seconds to compute the solution path
set.seed(1234)
system.time(
    est_dal <- elnet(
        x, y,
        alpha = 0.6,
        nlambda = 100,
        options = en_options_dal(),
        xtest = x_test
    )
)

\donttest{
# In comparison, the augmented LARS algorithm can take several minutes
set.seed(1234)
system.time(
    est_auglars <- elnet(
        x, y,
        alpha = 0.6,
        nlambda = 100,
        options = en_options_aug_lars(),
        xtest = x_test
    )
)
}
}
\references{
Tomioka, R., Suzuki, T. and Sugiyama, M. (2011).
    Super-Linear Convergence of Dual Augmented Lagrangian Algorithm
    for Sparse Learning.
    \emph{Journal of Machine Learning Research}
    \bold{12}(May):1537-1586.

Zou, H. and Hastie, T. (2005).
    Regularization and variable selection via the elastic net.
    \emph{Journal of the Royal Statistical Society}.
    Series B (Statistical Methodology), \bold{67}(2):301-320.
}
\seealso{
\code{\link{elnet_cv}} for automatic selection of the penalty
     parameter based on the cross-validated prediction error.
}