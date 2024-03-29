.serialize_MAP_1_0_6 <- new.env()
.serialize_MAP_1_0_6$loggers <- new.env()
.serialize_MAP_1_0_6$loggers$ThermoDatalogger <- "Thermo"
.serialize_MAP_1_0_6$loggers$Dendrometer <- "Dendro"
.serialize_MAP_1_0_6$sensor_ids <- new.env()
.serialize_MAP_1_0_6$sensor_ids$TMS_TMSmoisture <- "TMS_moist"
.serialize_MAP_1_0_6$sensor_ids$TS_T <- "Thermo_T"
.serialize_MAP_1_0_6$sensor_ids$DEND_T <- "Dendro_T"
.serialize_MAP_1_0_6$sensor_ids$DEND_TOMSTdendro <- "Dendro_raw"
.serialize_MAP_1_0_6$sensor_ids$HOBO_T_F <- "real"
.serialize_MAP_1_0_6$sensor_ids$HOBO_T_C <- "HOBO_T"
.serialize_MAP_1_0_6$sensor_ids$moisture <- "VWC"
.serialize_MAP_1_0_6$sensor_ids$RH_perc <- "RH"
.serialize_MAP_1_0_6$sensor_ids$wind <- "wind_speed"


#' Save myClim object
#'
#' This function was designed for saving the myClim data object to an 
#' .rds file, which can be later correctly loaded by any further version 
#' of myClim package with [mc_load]. This is the safest way how to store and 
#' share your myClim data.
#'
#' @template param_myClim_object
#' @param file path to output .rds file
#' @return RDS file saved at the output path destination
#' @examples
#' tmp_dir <- tempdir()
#' tmp_file <- tempfile(tmpdir = tmp_dir)
#' mc_save(mc_data_example_agg, tmp_file)
#' file.remove(tmp_file)
#' @export
mc_save <- function(data, file) {
    output_object <- .save_convert_classes_to_lists(data)
    saveRDS(output_object, file=file)
}

.save_convert_classes_to_lists <- function(data) {
    get_items <- function(item) {
        if(is(item, "list")) {
            return(.save_convert_classes_to_lists(item))
        } else if(is(item, "mc_Serializable")) {
            return(.model_object_to_list(item))
        }
        return(item)
    }
    return(purrr::map(data, get_items))
}

#' Load myClim object
#'
#' This function loads the myClim .rds data object saved with [mc_save].
#' The `mc_save` and `mc_load` functions secure that the myClim object is correctly 
#' loaded across myClim versions.
#'
#' @param file path to input .rds file
#' @return loaded myClim object
#' @examples
#' tmp_dir <- tempdir()
#' tmp_file <- tempfile(tmpdir = tmp_dir)
#' mc_save(mc_data_example_agg, tmp_file)
#' data <- mc_load(tmp_file)
#' file.remove(tmp_file)
#' @export
mc_load <- function(file) {
    obj_list <- readRDS(file=file)
    return(.load_convert_lists_to_classes(obj_list))
}

.load_convert_lists_to_classes <- function(obj_list) {
    is_raw <- obj_list$metadata$format_type == "raw"

    sensor_function <- function(item) {
        item <- .serialize_edit_sensor_list_before_load(item, obj_list$metadata$version)
        metadata <- .model_list_to_object(item$metadata)
        return(list(metadata=metadata, values=item$values,
                    calibration=item$calibration, states=item$states))
    }

    logger_function <- function(item) {
        item <- .serialize_edit_logger_list_before_load(item, obj_list$metadata$version)
        metadata <- .model_list_to_object(item$metadata)
        clean_info <- .model_list_to_object(item$clean_info)
        sensors <- purrr::map(item$sensors, sensor_function)
        return(list(metadata=metadata, clean_info=clean_info, datetime=item$datetime, sensors=sensors))
    }

    locality_function <- function(item) {
        item <- .serialize_edit_locality_list_before_load(item, obj_list$metadata$version)
        metadata <- .model_list_to_object(item$metadata)
        if(is_raw) {
            loggers <- purrr::map(item$loggers, logger_function)
            return(list(metadata=metadata, loggers=loggers))
        }
        sensors <- purrr::map(item$sensors, sensor_function)
        return(list(metadata=metadata, datetime=item$datetime, sensors=sensors))
    }

    localities <- purrr::map(obj_list$localities, locality_function)

    class_name <- if(is_raw) "mc_MainMetadata" else "mc_MainMetadataAgg"
    main_metadata <- .model_list_to_object(obj_list$metadata)

    return(myClimList(main_metadata, localities))
}

.serialize_edit_locality_list_before_load <- function(item, original_version) {
    if(original_version < "0.2.6") {
        item$metadata$elevation <- item$metadata$altitude
        item$metadata <- item$metadata[names(item$metadata) != "altitude"]
    }
    return(item)
}

.serialize_edit_logger_list_before_load <- function(item, original_version) {
    if(original_version < "1.1.0") {
        if(item$metadata$type == "HOBO") {
            item$metadata$type <- .model_const_LOGGER_HOBO_U23_001A
        }
    }
    if(original_version < "1.0.6") {
        if(item$metadata$type %in% names(.serialize_MAP_1_0_6$loggers)) {
            item$metadata$type <- .serialize_MAP_1_0_6$loggers[[item$metadata$type]]
        }
    }
    return(item)
}

.serialize_edit_sensor_list_before_load <- function(item, original_version) {
    if(original_version < "1.0.6") {
        if(item$metadata$sensor_id %in% names(.serialize_MAP_1_0_6$sensor_ids)) {
            item$metadata$sensor_id <- .serialize_MAP_1_0_6$sensor_ids[[item$metadata$sensor_id]]
        }
    }
    return(item)
}
