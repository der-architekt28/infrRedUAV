#' Calculation of the field of view of Apogee® radiometers
#'
#'
#' `apogee_ellipse_area` calculates the land surface temperature from radiance temperature
#'
#' @param ang_sfn Angle to surface normal as deviation between vertical axis and line of sight (numeric). Must be in degrees
#' @param ang_half Half angle to surface normal as deviation between vertical axis and line of sight (numeric). Must be in degrees
#' @param h_i Height of the instrument (numeric). Must be in meter
#' @param from_model States whether ang_half is derived from 'rm_model' (boolean). If TRUE, 'rm_model' must be given. Default = FALSE
#' @param rm_model Radiometer type if the model-specific 'ang_half' is unknown (character).
#'                 Allowed inputs are: "SI-111", "SI-121" or "SI-131"
#'
#' @return Either a spatial raster or a numeric value, depending on the function input
#'
#'
#' @author Lukas Regensburger



apogee_ellipse_area <- function(ang_sfn, ang_half=NULL, h_i, from_model=FALSE, rm_model=NULL) {

  # check input arguments

  validate_input <- function(x) {
    is.numeric(x)
  }

  # check allowed input range

  validate_range <- function(x, min_lim, max_lim, name) {
    if(x < min_lim || x > max_lim) {
      stop(paste("Error:", name, "contains values outside allowed range."))
    }
  }

  if(!validate_input(ang_sfn) || is.null(ang_sfn)) {
    stop("Error: 'ang_sfn' must be provided as numeric object.")
  }

  # retrieve ang_half when only the model type is specified

  if(from_model) {

    if(is.null(rm_model)) {
      stop("Error: When getting the half angle from the model type, 'rm_model' is required.")
    }

    if(!rm_model %in% c("SI-111", "SI-121", "SI-131")) {
      stop("Error: 'rm_model has to be one of the following:
           SI-111, SI-121 or SI-131.")
    }

    if(rm_model == "SI-111") {
      ang_half <- 22

    } else if (rm_model =="SI-121") {
      ang_half <- 18

    } else ang_half <- 14

  }

  # validate ang_half and h_i

  if(!validate_input(ang_half) || is.null(ang_sfn)) {
    stop("Error: 'ang_half' must be provided as numeric object.")
  }

  if(!validate_input(h_i) || is.null(h_i)) {
    stop("Error: 'h_i' must be provided as numeric object.")
  }

  # check if values are in allowed range

  validate_range(ang_sfn, 0, 90, "'ang_sfn'")

  validate_range(ang_half, 0, 90, "'ang_half'")

  validate_range(h_i, 0, 1000, "'h_i'")

  if(ang_sfn > 60) {
    warning("Warning: 'ang_sfn' has a value of more than 60° which may lead to unwanted results.")
  }

  # main calculation

  ang_sfn_rad <- ang_sfn*(pi/180)
  ang_half_rad <- ang_half*(pi/180)

  bo <- h_i*tan(ang_sfn_rad)
  do <- h_i*tan(ang_sfn_rad + ang_half_rad)
  ao <- h_i*tan(ang_sfn_rad - ang_half_rad)
  ad <- do - ao
  bd <- do - bo
  a <- ad / 2
  co <- a + ao
  bc <- co - bo
  bh <- h_i / cos(ang_sfn_rad)
  be <- tan(ang_half_rad)*bh
  b <- sqrt((be^2 * a^2) / (a^2 - bc^2))

  # paste half axes as console outputs

  message(
    paste("Great half axis =", round(a, 2))
  )

  message(
    paste("Small half axis =", round(b, 2))
  )

  # calculate the final area

  area = round((pi*a*b), 2)

  message(
    paste("Area =", area)
  )

  return(area)
}

