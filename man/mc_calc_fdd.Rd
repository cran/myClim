% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc.R
\name{mc_calc_fdd}
\alias{mc_calc_fdd}
\title{Freezing Degree Days}
\usage{
mc_calc_fdd(data, sensor, output_prefix = "FDD", t_base = 0, localities = NULL)
}
\arguments{
\item{data}{cleaned myClim object see \link{myClim-package}}

\item{sensor}{name of temperature sensor used for FDD calculation e.g. TMS_T3 see \code{names(mc_data_sensors)}}

\item{output_prefix}{name prefix of new FDD sensor (default "FDD")

name of output sensor consists of output_prefix and value t_base (FDD0_TMS_T3)}

\item{t_base}{threshold temperature for FDD calculation (default 0)}

\item{localities}{list of locality_ids for calculation; if NULL then all (default NULL)}
}
\value{
The same myClim object as input but with added virtual FDD sensor
}
\description{
This function creates a new virtual sensor on locality within the myClim data object.
The new virtual sensor provides FDD Freezing Degree Days.
}
\details{
The allowed step length for FDD calculation is day and shorter.
Function creates a new virtual sensor with the same time step as input data.
For shorter time steps than the day (which is however not intuitive for FDD)
the FDD value is the contribution of the time step to the freezing degree day.
Be careful while aggregating freezing degree days to longer periods
only meaningful aggregation function is \code{sum}, but myClim allows you to apply anything see \code{\link[=mc_agg]{mc_agg()}}.

Note that FDD is always positive number, despite summing freezing events. When you set
\code{t_base=-1} you get the sum of degree days below -1 °C but expressed in positive number
if you set \code{t_base=1} you get also positive number. Therefore pay attention to
name of output variable which contains \code{t_base} value. FDD1_TMS_T3, t_base=1 vs FDDminus1_TMS_T3, t_base=-1
}
\examples{
fdd_data <- mc_calc_fdd(mc_data_example_agg, "TMS_T3", localities = c("A2E32", "A6W79"))
fdd_agg <- mc_agg(fdd_data, list(TMS_T3=c("min", "max"), FDD5="sum"), period="day")
}
