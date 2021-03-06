% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/test_diversity.R
\docType{methods}
\name{test_diversity}
\alias{test_diversity}
\alias{test_diversity-method}
\alias{test_diversity,CountMatrix-method}
\title{Diversity Test}
\usage{
test_diversity(object, ...)

\S4method{test_diversity}{CountMatrix}(object, adjust = "holm", ...)
}
\arguments{
\item{object}{A \eqn{m \times p}{m x p} matrix of count data.}

\item{...}{Further arguments to be passed to internal methods.}

\item{adjust}{A \code{\link{character}} string specifying the method for
adjusting \eqn{p} values (see \code{\link[stats]{p.adjust}}).}
}
\value{
A \code{\link{numeric}} matrix.
}
\description{
Compares Shannon diversity between samples.
}
\details{
This test produces two sided pairwise comparisons: it returns a matrix of
 adjusted \eqn{p} values.
}
\examples{
## Shannon diversity test
merzbach_count <- as_count(merzbach)
div <- test_diversity(merzbach_count)

## Frequency Increment Test
## Coerce the merzbach dataset to a count matrix
## Keep only decoration types that have a maximum frequency of at least 50
keep <- apply(X = merzbach, MARGIN = 2, FUN = function(x) max(x) >= 50)
merzbach_count <- as_count(merzbach[, keep])

## The data are grouped by phase
## We use the row names as time coordinates (roman numerals)
set_dates(merzbach_count) <- rownames(merzbach)

fit <- test_fit(merzbach_count, simplify = TRUE)
}
\references{
Magurran, A. E. (1988). \emph{Ecological Diversity and its Measurement}.
 Princeton, NJ: Princeton University Press.
 DOI: \href{https://doi.org/10.1007/978-94-015-7358-0}{10.1007/978-94-015-7358-0}.
}
\seealso{
Other statistics: 
\code{\link{independance}},
\code{\link{refine}},
\code{\link{test_fit}()}
}
\author{
N. Frerebeau
}
\concept{statistics}
