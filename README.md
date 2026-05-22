# infrRedUAV

<br>
A small collection of versatile tools to be used for thermal infrared remote sensing, especially for UAV-based campaigns.

## Description and Features

UAV-based thermal imaging has become an emerging field of study in recent years, but features some additional challenges in comparison to conducting researches with satellite data.
Therefore, some of the post processing steps of field surveys can be simplified using R.
The package might be expanded in the future, to provide solutions to additional necessities as well.

As for the current version, the following functions with their respective workflows are included:
<br>
<br>
<br>

 ### <b>apogee_ellipse_area</b>
  <br>

   <img width="500" height="375" alt="image" src="https://github.com/user-attachments/assets/6940359e-70c9-4464-bdca-a18372201df2" />
   
   <i>Figure 1: Acquisition geometries for Apogee® radiometers</i>

<br>
<br>
 To obtain ground truth data for the surveyed area of interest, a common practice is to place stationary radiometers pointed to the ground. 
 For setting the temperature values recorded by the radiometer into relation with the temperature on each pixel of corresponding images acquired by the UAV, 
 one must have knowledge on the size of the footprint on each ground-based device. 
 
 The field of view projected onto the ground has an elliptical form, and its area is usually calculated from three inputs:
 
1. The angle of deviation from the surface normal, which in this case is the vertical axis
2. The so-called half angle as deviation between the line of sight from sensor perspective and each horizontal edge of the elliptical field of view 
3. The height of the radiometer
 
 For now, the function can only be applied to radiometers produced by Apogee Instruments®, 
 due to the model specifications and acquisition geometries being well described on the website: https://www.apogeeinstruments.com/field-of-view/
<br>
<br>

 Usage of the function:
 <br>
 ```
 apogee_ellipse_area <- function( ang_sfn, 
                                  ang_half=NULL,
                                  h_i, 
                                  from_model=FALSE, 
                                  rm_model=NULL) {      (...)
      
    return(area)
 }
 ```
Parameters:
- <b>ang_sfn</b> (numeric):     &nbsp;&nbsp;&nbsp;&nbsp;Angle to surface normal as devation between vertical axis and line of sight. Must be in degrees.
- <b>ang_half</b> (numeric):    &nbsp;&nbsp;&nbsp;&nbsp;Half angle to surface normal as devation between vertical axis and line of sight. Must be in degrees.
- <b>h_i</b> (numeric):         &nbsp;&nbsp;&nbsp;&nbsp;Height of the instrument (numeric). Must be in meter.
- <b>from_model</b> (boolean):  &nbsp;&nbsp;&nbsp;&nbsp;States whether ang_half is derived from 'rm_model'. If TRUE, 'rm_model' must be given. Default = FALSE.
- <b>rm_model</b> (character):  &nbsp;&nbsp;&nbsp;&nbsp;Radiometer type if the model-specific 'ang_half' is unknown. Allowed inputs are: "SI-111", "SI-121" or "SI-131".

<br>
<br>

 ### <b>corr_sensor_drift</b>
 <br>
   
   <img width="500" height="200" alt="image" src="https://github.com/user-attachments/assets/5492c235-b9ac-4f65-93f2-fbfa8e4117ee" />
   
   <i>Figure 2: Example for the internal temperature change observed for a standard UAV-mounted thermal sensor</i>

<br>
<br>
 A well-known source for over- or underestimated temperature values is the instability of thermal imaging sensor during the first phase of operation. 
 As often observed, the sensor temperature starts either at a significantly high or low level, before evening out around a certain value, where a predefined threshold is not exceeded anymore.
 <br>
 <br>
 In the literature, several methods can be found for compensating for the effects caused by the unstable sensor temperatures. While the distribution of thermal control points across the area of interest
 has been proven to be a reliable approach, the lack of resources or the presence of remote and complex terrain could make it necessary to rely on empirical methods.
<br>
<br>
 The workflow is as followed:
 <br>
 <br>
 First, it is determined when the sensor temperature reaches a stable phase. This is done regardless of the specified method, but uses the threshold defined by the user.
 <br>
 Calculation of relative time in seconds based on the provided absolute time stamps:
 <img width="787" height="51" alt="image" src="https://github.com/user-attachments/assets/60544a81-ba31-4ce0-a9e7-a717c1abd56f" />
 <br>
 The phase of stability is reached, when for the sensor temperature the following applies:
 <img width="780" height="59" alt="image" src="https://github.com/user-attachments/assets/d7018922-e201-4a92-ab3e-7d08ec40bc1d" />
 <br>
 <br>
 
 <b> --> sensor_only</b>
 <br>
 
 If the method ("sensor_only") is specified, the following algorithm is applied:
 <br>
 <br>
 
 The mean value of all T_sens which are proven as stable is considered as target value:
 <img width="782" height="78" alt="image" src="https://github.com/user-attachments/assets/d1a639ca-17ef-45d6-98c7-3304d36e17df" />
 <br>
 <br>
 With one of two fitting methods, a function is modelled on t_rel:
 <img width="784" height="48" alt="image" src="https://github.com/user-attachments/assets/5b6888ab-3d63-4988-ba23-3f60c0c70f60" />
 <br>
 <br>
 Subtracting the fitted values from the target value results in the correction value:
 <img width="788" height="51" alt="image" src="https://github.com/user-attachments/assets/adb99264-71d1-46fd-b97d-18642b6f6441" />
 <br>
 <br>
 The final corrected temperature is calculated as :
 <img width="783" height="54" alt="image" src="https://github.com/user-attachments/assets/08f7748c-3104-408f-bcb9-8dcf5e6ec82a" />

 <br>
 <br>
 <b> --> lst_dev</b>
 <br>
 
 If the method ("lst_dev") is specified, the following algorithm is applied:
 <br>
 <br>
 
 Now, the mean of the observed values during stability is taken:
 <img width="780" height="84" alt="image" src="https://github.com/user-attachments/assets/385da596-1310-4cf4-9442-677062f4e8a8" />
 <br>
 <br>
 Each observed temperature is subtracted from the target:
 <img width="781" height="52" alt="image" src="https://github.com/user-attachments/assets/23784b3b-9d60-426c-9abb-0d5039f4c2de" />
 <br>
 <br>
 In contrast to the first method, here the relationship between T_sens and deviation is exploited:
 <img width="780" height="50" alt="image" src="https://github.com/user-attachments/assets/ba110154-7b9d-40b9-8667-29e441e341f7" />
 <br>
 <br>
 The final corrected temperature is then calculated as:
 <img width="783" height="55" alt="image" src="https://github.com/user-attachments/assets/ac0bbb9a-99c3-4f4f-9a7a-6a2bb2c3d403" />

<br>
<br>

 Usage of the function:
 <br>
 ```
 corr_sensor_drift <- function(df,
                       col_tsens,
                       col_traw,
                       col_time,
                       method="sensor_only",
                       fit="spline",
                       degf=2,
                       threshold=0.3,
                       datetime_format) {  (...)
   return()
 }
```
Parameters:
- <b>df</b> (dataframe):     &nbsp;&nbsp;&nbsp;&nbsp;Input table. Must at least include columns for 'col_tsens', 'col_traw' and 'col_time'
- <b>col_tsens</b> (character):    &nbsp;&nbsp;&nbsp;&nbsp;Name of the column featuring the sensor temperature values. Values must be in degrees Celsius.
- <b>col_traw</b> (character):         &nbsp;&nbsp;&nbsp;&nbsp;Name of the column featuring the recorded temperature values, usually mean values of single images. Values must be in degrees Celsius.
- <b>col_time</b> (character):  &nbsp;&nbsp;&nbsp;&nbsp;Name of the column featuring acquisition time stamps. Must be in a recognized datetime format, which is specified by 'datetime_format'.
- <b>method</b> (character):  &nbsp;&nbsp;&nbsp;&nbsp;Method used to calculate deviations and corrected temperatures. Either "sensor_only" or "lst_dev".
- <b>fit</b> (character):     &nbsp;&nbsp;&nbsp;&nbsp;Mathematical method used for modelling variable relations. Either "polynomial" or "spline"; default is "spline".
- <b>degf</b> (numeric):     &nbsp;&nbsp;&nbsp;&nbsp;Degrees of freedom for function fitting. Default is 2. Increase with care to prevent overfitting.
- <b>threshold</b> (numeric):     &nbsp;&nbsp;&nbsp;&nbsp;Margin from minimum 'tsens' to define interval where 'tsens' is stable. Default is 0.3.
- <b>datetime_format</b> (character):     &nbsp;&nbsp;&nbsp;&nbsp;Describes format of 'col_time' to the algorithm. Must refer to a recognized datetime format. Common example would be "%Y-%m-%d %H:%M:%S"
 
  <br>
 <br>
 
 ### <b>rad2lst</b>
 <br>
 This function allows the transformation between the recorded radiant temperature and the land surface temperature (LST) of the area of interest, which usually marks a crucial step within the post-processing.
 The LST can be calculated from two methods:
 <br>
 <br>
 1. Using a direct approach with ε and LW_in only:
 <br>
 <br>
    <img width="300" height="97" alt="image" src="https://github.com/user-attachments/assets/46f4fdca-16b5-47d9-b0a1-d0bdf68ad51f" />

 <br>
 <br>
 
 2. Calculating the ambient or background temperature beforehand:
 <br>
    <img width="401" height="93" alt="image" src="https://github.com/user-attachments/assets/e994913e-4b39-49e7-b836-c192a50328df" />

<br>
<br>

Usage of the function:
<br>
```
rad2lst <- function(trad, 
                    emi, 
                    lw_in, 
                    use_tbg=FALSE, 
                    return_tbg=FALSE, 
                    tbg=NULL, 
                    rast_tol_fact=0.1) {   (...)
   return()
}
 ```
Parameters:
- <b>trad</b> (numeric)(SpatRaster):     &nbsp;&nbsp;&nbsp;&nbsp;Radiance temperature as single number or raster image.
- <b>emi</b> (numeric)(SpatRaster):    &nbsp;&nbsp;&nbsp;&nbsp;Surface emissivity as single number or raster image. Must be between 0 and 1.
- <b>lw_in</b> (numeric)(SpatRaster):         &nbsp;&nbsp;&nbsp;&nbsp;Incoming longwave radiation as single number or raster image. Must be > 0.
- <b>use_tbg</b> (boolean):  &nbsp;&nbsp;&nbsp;&nbsp;States whether background temperature instead of lw_in is used. If TRUE, 'return_tbg' must be FALSE and 'tbg' must be provided.
- <b>tbg</b> (character)(SpatRaster):  &nbsp;&nbsp;&nbsp;&nbsp;Background-, also referred to as ambient temperature, as single number or raster image.
- <b>return_tbg</b> (character):  &nbsp;&nbsp;&nbsp;&nbsp;States whether'tbg' is returned as well when using lw_in. Only possible if 'use_tbg' is FALSE.
- <b>rast_tol_fact</b> (character):  &nbsp;&nbsp;&nbsp;&nbsp;Applied when computing a minimum tolerance for raster comparison. Only needed if more than 1 input is a raster. Approximate values for orientation are < 0.5 when coordinates are in degree and < 0.001 when in geographical units.

<br>
<br>

## Getting Started

### Test data

In the directory "test_files"/inst/ext_data" one can find files which can be used for testing the function.
<br>
<br>
When testing "corr_sensor_drift", one may use the following files:
* survey.csv &nbsp;&nbsp;&nbsp;&nbsp; as input for "df"

When testing "rad2lst", one may use the following files:
* temperature_raw_uav.tif &nbsp;&nbsp;&nbsp;&nbsp; as input for "trad"
* emissivity.tif &nbsp;&nbsp;&nbsp;&nbsp; as input for "emi"

### Dependencies

* terra
* lubridate
* dplyr


## Authors

Author: Lukas Regensburger (Universität Würzburg)

## Version History
* 0.2 
* 0.1
    * Initial Release

## License

This project is licensed under License - see the LICENSE.md file for details

## Acknowledgements

* ArcticDroughtPaper by Niels Rietze https://github.com/nrietze/ArcticDroughtPaper
* README-Template by Dominique Pizzie https://gist.github.com/DomPizzie/7a5ff55ffa9081f2de27c315f5018afc

## References

1) Apogee Instruments, Inc. (2026). Apogee Infrared Radiometers. Von Apogee Instruments: https://www.apogeeinstruments.com/infraredradiometer/ abgerufen
2) Aragon, B., Johansen, K., Parkes, S., Malbeteau, Y., Al-Mashharawi, S., Al-Amoudi, T., . . . McCabe, M. F. (2020). A Calibration Procedure for Field and UAV-Based Uncooled Thermal Infrared Instruments. Sensors (20), 3316.
3) Boltzmann, L. (1884). Ableitung des Stefan’schen Gesetzes, betreffend die Abhängigkeit der Wärmestrahlung von der Temperatur aus der elektromagnetischen Lichttheorie. Annalen der Physik und Chemie (22), 291.
4) Kraaijenbrink, P. D., Litt, M., Steiner, J. F., Treichler, D., Koch, I., & Immerzeel, W. W. (2018). Mapping Surface Temperatures on a Debris-Covered Glacier With an Unmanned Aerial Vehicle. Front. Earth Sci. (6), 64.
5) Kuenzer, C., & Dech, S. (2013). Theoretical Background of Thermal Infrared Remote Sensing. In C. Kuenzer, & S. Dech, Thermal Infrared Remote Sensing (S. 1-26). Dordrecht: Springer Science+Business Media.
6) Naegeli, K., Adams, J. S., Bramati, G., Gärtner-Roer, I., Gröbner, J., & Rietze, N. (2026). Towards Best Practices in UAV Thermal Remote Sensing in Complex Environments. EGUsphere.
7) Planck, M. (1900). Entropie und Temperatur Strahlender Wärme. Ann. Phys. (306), 719-737.
8) Rietze, N., Assmann, J. J., Plekhanova, E., Naegeli, K., Damm, A., Maximov, T. C., . . . Schaepman-Strub, G. (2023). Summer drought weakens land surface cooling of tundra vegetation. Environ. Res. Lett. (19), 044043.
9) Stefan, J. (1879). Über die Beziehung zwischen der Wärmestrahlung und der Temperatur. Sitzungsberichte der Kaiserlichen Akademie der Wissenschaften in Wien (79), 391-428.
