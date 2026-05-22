#' Calculation of the land surface temperature from radiance temperature.
#' Additionally, the ambient background temperature can be returned or, if existing, used for calculation.
#'
#'
#' `rad2lst` calculates the land surface temperature from radiance temperature
#'
#' @param trad Radiance temperature as single number (numeric) or raster image (SpatRaster)
#' @param emi Surface emissivity as single number (numeric) or raster image (SpatRaster). Must be between 0 and 1.
#' @param lw_in Incoming longwave radiation as single number (numeric) or raster image (SpatRaster). Must be > 0.
#' @param tbg Background-, also referred to as ambient temperature, as single number (numeric) or raster image (SpatRaster)
#' @param use_tbg States whether background temperature instead of lw_in is used (boolean). If TRUE, 'return_tbg' must be FALSE.
#' @param return_tbg States whether'tbg' is returned as well when using lw_in (boolean). Only possible if 'use_tbg' is FALSE.
#' @param rast_tol_fact Applied when computing a minimum tolerance for raster comparison (numeric). Only needed if more than 1 input is a raster.
#'                      Approximate values for orientation are < 0.5 when coordinates are in degree and < 0.001 when in geographical units.
#'
#' @return Either a spatial raster or a numeric value, depending on the function input
#'
#'
#' @author Lukas Regensburger
#'
#' @export



rad2lst <- function(trad,
                    emi,
                    lw_in,
                    use_tbg=FALSE,
                    return_tbg=FALSE,
                    tbg=NULL,
                    rast_tol_fact=0.1) {

  # declare boltzmann constant as variable for later calculations

  boltzmann_const <- 5.6697e-8

  # validate input arguments for data type

  validate_input <- function(x) {

    is.numeric(x) ||
      inherits(x, "SpatRaster")
  }

  # check for mathematical consistency

  validate_range <- function(x, min_lim, max_lim, name) {

    if(inherits(x, "SpatRaster")) {

      invalid <- terra::global(
        (x < min_lim | x > max_lim),
        "max",
        na.rm = TRUE
      )[1,1]

      if(invalid == 1) {
        stop(paste("Error:", name, "contains values outside allowed range."))
      }

    } else {

      if(any(x < min_lim | x > max_lim, na.rm = TRUE)) {
        stop(paste("Error:", name, "contains values outside allowed range."))
      }

    }
  }

  # check the other values

  if(!validate_input(trad)) {
    stop("Error: 'trad' must be provided as numeric or raster object.")
  }

  validate_range(trad, -273.15, Inf, "Input temperature")

  if(!validate_input(emi)) {
    stop("Error: 'emi' must be provided as numeric or raster object.")
  }

  # emissivity has to be between 0 and 1

  validate_range(emi, 0, 1, "Emissivity")


  if(use_tbg && return_tbg) {
    stop("Error: If background temperature is used, it cannot be calculated within the same operation.")
  }

  # transformate trad to kelvin

  trad_kelvin <- trad + 273.15

  # calculation using given background temperature

  if(use_tbg) {

    if(is.null(tbg)) {
      stop("Error: The formula using the background temperature 'tbg' is specified, but there seems to be no value for 'tbg'.")
    }

    if(!validate_input(tbg)) {
      stop("Error:'tbg' must be provided as numeric or raster object.")
    }

    validate_range(tbg, -273.15, Inf, "Background temperature")

    # transformate tbg to kelvin

    tbg_kelvin <- tbg + 273.15

    # collect input arguments

    inputs <- list(trad_kelvin=trad_kelvin, emi=emi, tbg_kelvin=tbg_kelvin)

    # collect all arguments provided as raster

    raster_inputs <- inputs[
      sapply(inputs, function(x)
        inherits(x, "SpatRaster"))
    ]

    # check raster inputs for spatial consistency

    if(length(raster_inputs) > 1) {

      ref <- raster_inputs[[1]]
      ref_res <- terra::res(ref)
      offset <- min(ref_res)*rast_tol_fact

      for(i in 2:length(raster_inputs)) {
        validate_extent <- terra::compareGeom(
          ref, raster_inputs[[i]], tolerance = offset, stopOnError = FALSE
        )

        if(!validate_extent) {
          stop(
            paste("Error:", names(raster_inputs)[1], "and", names(raster_inputs)[i], "do not have the same spatial extent.")
          )
        }
      }

    }

    # main calculation: land surface temperature from emissivity and background temperature

    lst_kelvin <- ((trad_kelvin^4 - (1 - emi) * tbg_kelvin^4) / emi)^(1/4)
    lst <- lst_kelvin - 273.15

    return(lst)
  }

  # calculating background temperature by provided longwave radiation

  if(!validate_input(lw_in)) {
    stop("Error: 'lw_in' must be provided as numeric or raster object.")
  }

  validate_range(lw_in, 0, Inf, "Longwave radiation")

  inputs <- list(trad_kelvin=trad_kelvin, emi=emi, lw_in=lw_in)

  raster_inputs <- inputs[
    sapply(inputs, function(x)
      inherits(x, "SpatRaster"))
  ]

  # check raster inputs for spatial consistency

  if(length(raster_inputs) > 1) {

    ref <- raster_inputs[[1]]
    ref_res <- terra::res(ref)
    offset <- min(ref_res)*rast_tol_fact

    for(i in 2:length(raster_inputs)) {
      validate_extent <- terra::compareGeom(
        ref, raster_inputs[[i]], tolerance = offset, stopOnError = FALSE
      )

      if(!validate_extent) {
        stop(
          paste("Error:", names(raster_inputs)[1], "and", names(raster_inputs)[i], "do not have the same spatial extent.")
        )
      }
    }

  }

  # calculate background temperature

  tbg_kelvin <- (lw_in / boltzmann_const)^(1/4)

  lst_kelvin <- (((boltzmann_const * trad_kelvin^4) -
                    ((1 - emi) * lw_in)) /
                   (boltzmann_const * emi))^(1/4)

  # transform back to celsius

  lst <- lst_kelvin - 273.15
  tbg <- tbg_kelvin - 273.15

  if(return_tbg) {

    return(list(
      background = tbg,
      surface = lst
    ))
  }

  return(lst)
}
