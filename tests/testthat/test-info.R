test_that("mc_info_count", {
    data <- mc_read_data("../data/TOMST/files_table.csv", clean=FALSE)
    count_table <- mc_info_count(data)
    expect_equal(count_table$count, c(3, 3, 9))
    cleaned_data <- mc_prep_clean(data, silent=T)
    agg_data <- mc_agg(cleaned_data)
    count_table <- mc_info_count(agg_data)
    expect_equal(count_table$count, c(3, 9))
})

test_that("mc_info_clean", {
    expect_warning(cleaned_data <- mc_read_files("../data/clean-datetime_step", "TOMST", silent=T))
    info_table <- mc_info_clean(cleaned_data)
    expect_equal(colnames(info_table), c("locality_id", "serial_number", "start_date", "end_date", "step_seconds", "count_duplicities", "count_missing", "count_disordered", "rounded"))
})

test_that("mc_info", {
    data <- mc_read_files("../data/clean-datetime_step", "TOMST", clean=FALSE)
    info_data <- mc_info(data)
    expect_equal(colnames(info_data), c("locality_id", "serial_number", "sensor_id", "sensor_name", "start_date", "end_date", "step_seconds", "period", "min_value", "max_value", "count_values", "count_na"))
    expect_equal(nrow(info_data), 17)
    expect_warning(cleaned_data <- mc_prep_clean(data, silent=T))
    info_cleaned_data <- mc_info(cleaned_data)
    expect_equal(nrow(info_cleaned_data), 17)
    expect_warning(agg_data <- mc_agg(cleaned_data, list(TMS_T1=c("min", "max"), TMS_moist="mean"), "hour"))
    info_agg_data <- mc_info(agg_data)
    expect_equal(nrow(info_agg_data), 12)
})

test_that("mc_info no data FIX", {
    data <- mc_read_files("../data/eco-snow", "TOMST", silent=T)
    all_data <- mc_agg(data, "mean", "all")
    table <- mc_info(all_data)
    expect_equal(nrow(table), 8)
})

test_that("mc_info_meta", {
    data <- mc_read_data("../data/TOMST/files_table.csv", "../data/TOMST/localities_table.csv", clean=FALSE)
    meta_info <- mc_info_meta(data)
    expect_equal(colnames(meta_info), c("locality_id", "lon_wgs84", "lat_wgs84", "elevation", "tz_offset"))
    expect_equal(nrow(meta_info), 3)
    cleaned_data <- mc_prep_clean(data, silent=T)
    agg_data <- mc_agg(cleaned_data)
    agg_meta_info <- mc_info_meta(agg_data)
    expect_equal(agg_meta_info, meta_info)
})

test_that("mc_info_logger", {
    data <- mc_read_files("../data/join", "TOMST", clean=FALSE)
    info_data <- mc_info_logger(data)
    expect_equal(colnames(info_data), c("locality_id", "index", "serial_number", "logger_type", "start_date", "end_date", "step_seconds"))
    expect_equal(nrow(info_data), 8)
    cleaned_data <- mc_prep_clean(data, silent=T)
    info_cleaned_data <- mc_info_logger(cleaned_data)
    expect_equal(nrow(info_cleaned_data), 8)
    expect_true(all(!is.na(info_cleaned_data$step_seconds)))
    agg_data <- mc_agg(mc_join(cleaned_data))
    expect_error(mc_info_logger(agg_data))
})

test_that("mc_info_join", {
    data <- mc_read_files("../data/join", "TOMST", clean=TRUE, silent=TRUE)
    data$localities$`94184103`$loggers[[1]]$sensors$TMS_T1$values <- data$localities$`94184103`$loggers[[1]]$sensors$TMS_T1$values + 1
    table <- mc_info_join(data)
    expect_equal(colnames(table), c("locality_id", "count_loggers", "count_joined_loggers", "count_data_conflicts", "count_errors"))
    expect_equal(nrow(table), 4)
    expect_true(is.integer(table$count_loggers))
    expect_true(is.integer(table$count_joined_loggers))
    expect_true(is.integer(table$count_data_conflicts))
    expect_true(is.integer(table$count_errors))
    expect_equal(table$count_data_conflicts[table$locality_id == "94184103"], 1)
    data1 <- mc_filter(data, localities = "91184101")
    data2 <- mc_filter(data, localities = "94184103")
    data1 <- mc_prep_meta_locality(data1, values=list(`91184101`="ABC"), param_name="locality_id")
    data2 <- mc_prep_meta_locality(data2, values=list(`94184103`="ABC"), param_name="locality_id")
    merged_data <- mc_prep_merge(list(data1, data2))
    merged_data$localities$ABC$loggers[[1]]$metadata@type <- "TMS"
    expect_warning(table2 <- mc_info_join(merged_data))
    expect_equal(table2$count_errors, 1)
})

test_that("mc_info_states", {
    data <- mc_read_data("../data/TOMST/files_table.csv", silent=TRUE)
    states <- mc_info_states(data)
    expect_equal(colnames(states), c("locality_id", "logger_index", "logger_type", "sensor_name",
                                     "tag", "start", "end", "value"))
    expect_equal(nrow(states), 9)
    agg_data <- mc_agg(data, "max", period="hour")
    states <- mc_info_states(agg_data)
    expect_equal(colnames(states), c("locality_id", "logger_index", "logger_type", "sensor_name",
                                     "tag", "start", "end", "value"))
    expect_equal(nrow(states), 9)
    expect_true(all(is.na(states$logger_index)))
})
