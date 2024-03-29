% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc.R
\name{mc_calc_tomst_dendro}
\alias{mc_calc_tomst_dendro}
\title{Converting Tomst dendrometer values to micrometers}
\usage{
mc_calc_tomst_dendro(
  data,
  dendro_sensor = mc_const_SENSOR_Dendro_raw,
  output_sensor = mc_const_SENSOR_dendro_l_um,
  localities = NULL
)
}
\arguments{
\item{data}{cleaned myClim object see \link{myClim-package}}

\item{dendro_sensor}{name of change in stem size sensor to be converted from raw to micrometers (default "Dendro_raw") see \code{names(mc_data_sensors)}}

\item{output_sensor}{name of new change in stem size sensor (default "dendro_l_um")}

\item{localities}{list of locality_ids for calculation; if NULL then all (default NULL)}
}
\value{
myClim object same as input but with added dendro_l_um sensor
}
\description{
This function creates a new virtual sensor on locality within the myClim data object.
The virtual sensor provides the values of the change in stem size converted from raw
Tomst units to micrometers. Note that newer versions of Tomst Lolly
software can directly convert raw Tomst units to micrometers.
}
\examples{
agg_data <- mc_calc_tomst_dendro(mc_data_example_agg, localities="A1E05")
}
