# infrRedUAV

A small collection of versatile tools to be used for thermal infrared remote sensing, especially for UAV-based campaigns.

## Description and Features

UAV-based thermal imaging has become an emerging field of study in recent years, but features some additional challenges in comparison to conducting researches with satellite data.
Therefore, some of the post processing steps of field surveys can be simplified using R.
The package might be expanded in the future, to provide solutions to additional necessities as well.

As for the current version, the following functions with their respective workflows are included:
<br>
<br>
<br>

 * <b>apogee_ellipse_area</b>

   <img width="500" height="375" alt="image" src="https://github.com/user-attachments/assets/6940359e-70c9-4464-bdca-a18372201df2" />
   
   Figure 1: Acquisition geometries for Apogee® radiometers
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
<br>
 * <b>corr_sensor_drift</b>
   
   <img width="500" height="200" alt="image" src="https://github.com/user-attachments/assets/5492c235-b9ac-4f65-93f2-fbfa8e4117ee" />
   
   Figure 2: Example for the internal temperature change observed for a standard UAV-mounted thermal sensor
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
 <br>
 
 * <b>rad2lst</b>
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


 

## Getting Started

### Dependencies

* terra
* lubridate
* dplyr


## Authors

Author: Lukas Regensburger (Universität Würzburg)

## Version History

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
