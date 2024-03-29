% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model.R
\name{[.myClimList}
\alias{[.myClimList}
\title{Extract localities with []}
\usage{
\method{[}{myClimList}(x, ...)
}
\arguments{
\item{x}{myClim object see \link{myClim-package}}

\item{...}{indexes for extract localities}
}
\value{
myClim object with subset of localities see \link{myClim-package}
}
\description{
Using [] for extract localities.
}
\examples{
filtered_data <- mc_data_example_raw[1:2]
}
