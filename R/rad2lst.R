
rad2lst <- function(rad, emi, lw_in, use_tbg=FALSE, return_tbg=FALSE, tbg=NULL) {

  boltzmann_const <- 5.6697e-8

  validate_input <- function(x) {

    is.numeric(x) ||
      inherits(x, "SpatRaster") ||
      inherits(x, "Raster")
  }

  if(!validate_input(rad)) {
    stop("Error: 'rad' must be numeric or a raster object.")
  }

  if(!validate_input(emi)) {
    stop("Error: 'emi' must be numeric or a raster object.")
  }

  if(use_tbg && return_tbg) {
    stop("Error: If background temperature is used, it cannot be calculated within the same operation.")
  }

  # transformate rad to kelvin
  rad_kelvin <- rad + 273.15

  # calculation using given background temperature

  if(use_tbg) {

    if(is.null(tbg)) {
      stop("Error: The formula using the background temperature 'tbg' is specified, but there seems to be no value for 'tbg'.")
    }

    if(!validate_input(tbg)) {
      stop("Error:'tbg' must be numeric or a raster object.")
    }

    # transformate tbg to kelvin
    tbg_kelvin <- tbg + 273.15

    inputs <- list(rad_kelvin=rad_kelvin, emi=emi, tbg_kelvin=tbg_kelvin)

    raster_inputs <- inputs[
      sapply(inputs, function(x)
        inherits(x, "SpatRaster") ||
          inherits(x, "Raster"))
    ]

    if(length(raster_inputs) > 1) {

      ref <- raster_inputs[[1]]
      ref_res <- terra::res(ref)
      offset <- min(ref_res)*0.001

      for(i in 2:length(raster_inputs)) {
        validate_extent <- terra::compareGeom(
          ref, raster_inputs[[i]], tolerance = offset, stopOnError = FALSE
        )

        if(!validate_extent) {
          stop(
            paste("Error:", names(raster_inputs)[1], "and", names(rasater_inputs)[i], "do not have the same spatial extent.")
          )
        }
      }

    }

    lst_kelvin <- ((rad_kelvin^4 - (1 - emi) * tbg_kelvin^4) / emi)^(1/4)
    lst <- lst_kelvin - 273.15

    return(lst)
  }

  # calculating background temperature by provided longwave radiation

  if(is.null(lw_in)) {
    stop("'lw_in' must be provided.")
  }

  if(!validate_input(lw_in)) {
    stop("'lw_in' must be numeric or a raster object.")
  }

  inputs <- list(rad_kelvin=rad_kelvin, emi=emi, lw_in=lw_in)

  raster_inputs <- inputs[
    sapply(inputs, function(x)
      inherits(x, "SpatRaster") ||
        inherits(x, "Raster"))
  ]

  if(length(raster_inputs) > 1) {

    ref <- raster_inputs[[1]]
    ref_res <- terra::res(ref)
    offset <- min(ref_res)*0.001

    for(i in 2:length(raster_inputs)) {
      validate_extent <- terra::compareGeom(
        ref, raster_inputs[[i]], tolerance = offset, stopOnError = FALSE
      )

      if(!validate_extent) {
        stop(
          paste("Error:", names(raster_inputs)[1], "and", names(rasater_inputs)[i], "do not have the same spatial extent.")
        )
      }
    }

  }

  tbg_kelvin <- (lw_in / boltzmann_const)^(1/4)

  lst_kelvin <- (((boltzmann_const * rad_kelvin^4) -
                    ((1 - emi) * lw_in)) /
                   (boltzmann_const * emi))^(1/4)

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
