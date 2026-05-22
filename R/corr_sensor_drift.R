#' Correction of temperature values acquired by an unstable thermal camera
#' Adds the amount of necessary correction and the corrected temperature as new_columns to an existing dataframe
#'
#'
#' `corr_sensor_drift` provides two correction methods to compensate unstable thermal cameras
#'
#' @param df Input table (dataframe). Must at least include columns for 'col_tsens', 'col_traw' and 'col_time'
#' @param col_tsens Name of the column featuring the sensor temperature values (character). Values must be in degrees Celsius
#' @param col_traw Name of the column featuring the recorded temperature values, usually mean values of single images (character).
#'                 Values must be in degrees Celsius.
#' @param col_time Name of the column featuring acquisition time stamps (character).
#'                 Must be in a recognized datetime format, which is specified by 'datetime_format'
#' @param method Method used to calculate deviations and corrected temperatures (character). Either "sensor_only" or "lst_dev", see also the README-file
#' @param fit Mathematical method used for modelling variable relations (character). Either "polynomial" or "spline"; default is "spline"
#' @param degf Degrees of freedom for function fitting (numeric). Default is 2. Increase with care to prevent overfitting
#' @param threshold Margin from minimum 'tsens' to define interval where 'tsens' is stable (numeric). Default is 0.3
#' @param datetime_format Describes format of 'col_time' to the algorithm (character).
#'                        Must refer to a recognized datetime format. Common example would be "%Y-%m-%d %H:%M:%S"
#'
#'
#' @return Input table with amount of correction and corrected temperature added as new columns
#'
#'
#' @author Lukas Regensburger
#'
#' @export



corr_sensor_drift <- function(df,
                       col_tsens,
                       col_traw,
                       col_time,
                       method="sensor_only",
                       fit="spline",
                       degf=2,
                       threshold=0.3,
                       datetime_format) {


  # check inputs

  if(!is.data.frame(df)) {
    stop("Error: 'df' must be provided as dataframe object.")
  }

  if(is.null(col_tsens) || is.null(col_traw) || is.null(col_time)) {
    stop("Error: Arguments 'col_tsens', 'col_traw' and 'col_time' are required.")
  }

  if(is.null(method)) {
    stop("Error: A calculation method must be specified.")
  }

  validate_cols <- function(x, y, z) {
    is.character(x) && is.character(y)  && is.character(z)
  }

  if(!validate_cols(col_tsens, col_time, method)) {
    stop("Error: Arguments 'col_tsens', 'col_time' and 'method' must be of type character.")
  }

  if(!fit %in% c("spline", "polynomial")) {
    stop("Error: 'fit' must be either 'spline' or 'polynomial'.")
  }

  if(!method %in% c("sensor_only", "lst_dev")) {
    stop("Error: 'method' must be either 'sensor_only' or 'lst_dev'.")
  }

  validate_integer <- function(x, tol = .Machine$double.eps^0.5) {
    abs(x - round(x)) < tol
  }

  if(!validate_integer(degf) || degf < 1) {
    stop("Error: 'degf' must be a positive integer number.")
  }

  if(threshold < 0){
    stop("Error: 'threshold' must be greater than 0.")
  }

  # read arguments, assign variables

  tsens <- df[[col_tsens]]
  traw <- df[[col_traw]]
  time <- as.POSIXct(df[[col_time]], format = datetime_format)

  # calculate relative time

  rel_time = as.numeric(difftime(
    time,
    min(time),
    units = "secs"
  ))

  # function for time until stability

  timespan_fun <- function(timespan) {
    timespan <- round(timespan)
    h <- timespan %/% 3600
    m <- (timespan %% 3600) %/% 60
    s <- timespan %% 60

    sprintf("%02d:%02d:%02d", h, m, s)
  }

  # METHOD: SENSOR ONLY

  if(method == "sensor_only") {

    # create new dataframe

    df_sensor_only <- data.frame(x = rel_time,
                                 y = tsens,
                                 traw = traw,
                                 abs_time = time)

    # check if stability is reached

    df_sensor_only <- df_sensor_only %>%
      dplyr::mutate(is_stable = dplyr::if_else(y <= (min(y) + threshold) & y >= min(y), 1, 0))

    if(sum(df_sensor_only$is_stable == 1) <= 1) {
      stop("Error: The Sensor does not reach a stable phase. Please check your input data or consider using a higher threshold.")
    }

    if(sum(df_sensor_only$is_stable == 1) < 5) {
      warning("Warning: Number of stable temperature recordings is below 5. Please check your input data or consider using a higher threshold.")
    }

    # calculate mean tsens during stability phase

    tsens_target <- mean(df_sensor_only$y[df_sensor_only$is_stable == 1])

    # check when sensor stability is reached

    stabletime_abs <- df_sensor_only$abs_time[min(which(df_sensor_only$is_stable == 1))]

    stabletime_rel <- df_sensor_only %>%
      dplyr::filter(abs_time == stabletime_abs) %>%
      dplyr::pull(x)

    timespan_out <- timespan_fun(stabletime_rel)

    message(
      paste("Sensor stability is reached at", stabletime_abs, "after", timespan_out)
    )

    # further prepare dataframe for fitting

    if(fit == "polynomial") {     # polynomial fitting

      fit_poly <- stats::lm(y ~ poly(x, degf), data = df_sensor_only)
      pred_poly <- stats::predict(fit_poly, newdata = list(x =  df_sensor_only$x))
      corr_poly <- tsens_target - pred_poly
      tnew_poly <- df_sensor_only$traw - corr_poly

      # add the correction and the corrected temperature as new columns

      df <- df %>%
        dplyr::mutate(Corr_Factor = corr_poly,
               LST_driftcorr = tnew_poly)

      return(df)
    }

    if(fit == "spline") {     # spline fitting

      fit_spline <- stats::lm(y ~ splines::ns(x, degf), data = df_sensor_only)
      pred_spline <- stats::predict(fit_spline, newdata = list(x =  df_sensor_only$x))
      corr_spline <- tsens_target - pred_spline
      tnew_spline <- df_sensor_only$traw - corr_spline

      # add the correction and the corrected temperature as new columns

      df <- df %>%
        dplyr::mutate(Corr_Factor = corr_spline,
               LST_driftcorr = tnew_spline)

      return(df)
    }

  }


  # METHOD: LST_DEV

  if(method == "lst_dev") {

    # create new dataframe
    df_lst_dev <- data.frame(x = tsens,
                             traw = traw,
                             abs_time = time,
                             rel_time=rel_time)

    # check if stability is reached

    df_lst_dev <- df_lst_dev %>%
      dplyr::mutate(is_stable = dplyr::if_else(x <= (min(x) + threshold) & x >= min(x), 1, 0))

    if(sum(df_lst_dev$is_stable == 1) <= 1) {
      stop("Error: The Sensor does not reach a stable phase. Please check your input data or consider using a higher threshold.")
    }

    if(sum(df_lst_dev$is_stable == 1) < 5) {
      warning("Warning: Number of stable temperature recordings is below 5. Please check your input data or consider using a higher threshold.")
    }

    # check when stability is reached

    stabletime_abs <- df_lst_dev$abs_time[min(which(df_lst_dev$is_stable == 1))]

    stabletime_rel <- df_lst_dev %>%
      dplyr::filter(abs_time == stabletime_abs) %>%
      dplyr::pull(rel_time)

    timespan_out <- timespan_fun(stabletime_rel)

    message(
      paste("Sensor stability is reached at", stabletime_abs, "after", timespan_out)
    )

    # if needed, further prepare dataframe for fitting

    traw_target <- mean(df_lst_dev$traw[df_lst_dev$is_stable == 1])
    df_lst_dev <- df_lst_dev %>%
      dplyr::mutate(y = traw - traw_target)


    if(fit == "polynomial") {     # polynomial fitting

      fit_poly <- stats::lm(y ~ poly(x, degf), data = df_lst_dev)
      pred_poly <- stats::predict(fit_poly, newdata = list(x =  df_lst_dev$x))
      tnew_poly <- df_lst_dev$traw - pred_poly

      # add the correction and the corrected temperature as new columns

      df <- df %>%
        dplyr::mutate(Corr_Factor = pred_poly,
               LST_driftcorr = tnew_poly)

      return(df)

    }

    if(fit == "spline") {     # spline fitting

      fit_spline <- stats::lm(y ~ splines::ns(x, degf), data = df_lst_dev)
      pred_spline <- stats::predict(fit_spline, newdata = list(x =  df_lst_dev$x))
      tnew_spline <- df_lst_dev$traw - pred_spline

      # add the correction and the corrected temperature as new columns

      df <- df %>%
        dplyr::mutate(Corr_Factor = pred_spline,
               LST_driftcorr = tnew_spline)

      return(df)
    }

  }

}
