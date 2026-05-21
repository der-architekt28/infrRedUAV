
apogee_ellipse_area <- function(ang_sfn, ang_half=NULL, h_i, from_model=FALSE, rm_model) {

  validate_input <- function(x) {
    is.numeric(x)
  }

  if(!validate_input(ang_sfn) || is.null(ang_sfn)) {
    stop("Error: 'ang_sfn' must be provided as numeric object.")
  }

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

  if(!validate_input(ang_half) || is.null(ang_sfn)) {
    stop("Error: 'ang_half' must be provided as numeric object.")
  }

  if(!validate_input(h_i) || is.null(ang_sfn)) {
    stop("Error: 'h_i' must be provided as numeric object.")
  }

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

  paste("Great half axis =", a)
  paste("Small half axis =", b)

  area = round((pi*a*b), 2)

  return(area)
}

