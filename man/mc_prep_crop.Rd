% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep.R
\name{mc_prep_crop}
\alias{mc_prep_crop}
\title{Crop datetime}
\usage{
mc_prep_crop(
  data,
  start = NULL,
  end = NULL,
  localities = NULL,
  end_included = TRUE
)
}
\arguments{
\item{data}{myClim object see \link{myClim-package}}

\item{start}{optional; POSIXct datetime \strong{in UTC}; single value or vector; start datetime is included (default NULL)}

\item{end}{optional, POSIXct datetime \strong{in UTC}; single value or vector (default NULL)}

\item{localities}{vector of locality_ids to be cropped; if NULL then all localities are cropped (default NULL)}

\item{end_included}{if TRUE then end datetime is included (default TRUE), see details}
}
\value{
cropped data in the same myClim format as input.
}
\description{
This function crop data by datetime
}
\details{
Function is able to crop data from \code{start} to \code{end} but works also
with \code{start} only and \code{end} only. When only \code{start} is provided, then function crops only
the beginning of the tim-series and vice versa with end.

If \code{start} or \code{end} is a single POSIXct value, it is used for all or selected localities (regular crop).
However, if \code{start} and \code{end} are vectors of POSIXct values with the same length as the localities vector,
each locality is cropped by its own time window (irregular crop).

The \code{end_included} parameter is used for selecting, whether to return data which contains \code{end}
time or not. For example when cropping the data to rounded days, typically users use midnight.
2023-06-15 00:00:00 UTC. But midnight is the last date of ending day and the same
time first date of the next day. Thus, there will be the last day with single record.
This can be confusing in aggregation (e.g. daily mean of single record per day, typically NA) so
sometimes it is better to exclude end and crop on 2023-06-14 23:45:00 UTC (15 minutes records).
}
\examples{
cropped_data <- mc_prep_crop(mc_data_example_clean, end=as.POSIXct("2020-02-01", tz="UTC"))
}
