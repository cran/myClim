% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep.R
\name{mc_prep_TMSoffsoil}
\alias{mc_prep_TMSoffsoil}
\title{Detection of out-of-soil measurements from TMS logger}
\usage{
mc_prep_TMSoffsoil(
  data,
  localities = NULL,
  soil_sensor = mc_const_SENSOR_TMS_T1,
  air_sensor = mc_const_SENSOR_TMS_T2,
  moist_sensor = mc_const_SENSOR_TMS_moist,
  output_sensor = "off_soil",
  smooth = FALSE,
  smooth_window = 10,
  smooth_threshold = 0.5,
  sd_threshold = 0.76085,
  minmoist_threshold = 721.5
)
}
\arguments{
\item{data}{cleaned myClim object see \link{myClim-package}}

\item{localities}{names of localities; if NULL then all (default NULL)}

\item{soil_sensor}{character, soil temperature sensor (default \code{mc_const_SENSOR_TMS_T1})}

\item{air_sensor}{character, air temperature sensor (default \code{mc_const_SENSOR_TMS_T2})}

\item{moist_sensor}{character, soil moisture sensor (default \code{mc_const_SENSOR_TMS_moist})}

\item{output_sensor}{character, name of virtual sensor to store ouptup values (default "off_soil")}

\item{smooth}{logical, smooth out isolated faulty/correct records using floating window (default FALSE)}

\item{smooth_window}{integer, smooth floating window width (in days) (default 10)}

\item{smooth_threshold}{numeric, floating window threshold for detection of faulty records. (default 0.5)}

\item{sd_threshold}{numeric, threshold value for the criteria on the ratio of standard deviation of the soil sensor
to the above-ground sensor temperatures (default 0.76085)}

\item{minmoist_threshold}{numeric, threshold value for criteria on the minimum soil moisture (default 721.5)}
}
\value{
numeric vector (0 = correct measurement, 1 = faulty measurement) stored as virtual sensor in myClim object
}
\description{
This function creates new virtual sensor labelling anomalies in TMS logger caused by displacement out of from soil.
}
\details{
TMS loggers, when correctly installed in the soil, exhibit certain temperature and soil moisture signal characteristics.
Temperature varies the most at the soil interface, and temperature fluctuations in the soil are minimized.
The moisture signal from a sensor that has lost direct contact with the soil is reduced.
The following criteria are used for detecting faulty measurements: the ratio of the standard deviations of the soil
sensor to the above-ground sensor within 24h moving window is greater than the defined threshold (default 0.76085),
and simultaneously, the soil moisture minimum within 24h mowing window is less than 721.5.
Optionally, the prediction results can be smoothed using a floating window to average-out unlikely short periods detected by the algorithm.
Selection and parametrization of criteria was done using a recursive partitioning (rpart::rpart)
on the training set of 7.8M readings in 154 TMS timeseries from different environmental settings (temperate forests, tropical rainforest, cold desert, alpine and subnival zone,
and invalid measurements from loggers stored in the office or displaced from the soil).
Sensitivity of the method (true positive rate) on was 95.1\% and specificity (true negative rate) was 99.4\% using function default parameters.
Smoothing with 10 day floating window increased sensitivity to 96.8\% while retaining specifity at the same level of 99.4\%.
Decreasing 'smooth_threshold' below 0.5 will extend periods flagged as faulty measurement.
}
\examples{
data <- mc_read_files(system.file("extdata", "data_93142760_201904.csv", package = "myClim"),
                      "TOMST")
data <- mc_prep_TMSoffsoil(data)
mc_plot_line(data, sensors = c("off_soil","TMS_T1", "TMS_T2","TMS_T3"))
}
