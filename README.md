# GeoPressureTemplate

Analyzing geolocator data with pressure is full of potential, but the the path is long and the journey can be challenging. `GeoPressureTemplate` is a [Github repository template](https://docs.github.com/articles/creating-a-repository-from-a-template/) containing a start-up R project to make that journey easier.

## :mag_right: What is this template and who is it for? 

`GeoPressureTemplate` aims to help researchers analyse their geolocator data with [`GeoPressureR`](https://raphaelnussbaumer.com/GeoPressureR/). It provides the backbone R code containing the folder structure and R script to store your data, analyse it and produce trajectory figures. 

In essence, it contains the code from all the [GeoPressureManual](https://raphaelnussbaumer.com/GeoPressureManual) packaged in `.qmd` `.R` files to make it easy for you to apply it to your own data. 

## :computer: What do you need to use this template? 

- Geolocator data (called `tag`) containing at least pressure data, but optionally also light and acceleration data.
- Have read the [GeoPressureManual](https://raphaelnussbaumer.com/GeoPressureManual) (:warning: You should be familiar with the **full process involved** before starting with your own project)


## :file_folder: Project structure 

Following a mix of [rrrpkg](https://github.com/ropensci/rrrpkg#getting-started-with-a-research-compendium), [rrtools](https://github.com/benmarwick/rrtools#4-rrtoolsuse_analysis) and [cookiecutter data science](http://drivendata.github.io/cookiecutter-data-science/#directory-structure) the project contains: 

```
GeoPressureTemplate
├── DESCRIPTION          		                # project metadata and dependencies
├── README.md            		                # top-level description of content and guide to users
├── GeoPressureTemplate.Rproj               # R project file
├── LICENCES.md                             # specify the conditions of use and reuse of the code, data & text
├── data                                    
│   ├── raw_tag                             # Raw geolocator data grouped by tag id
│   │   ├── 18LX
│   │   │   ├── 18LX_20180725.acceleration
│   │   │   ├── 18LX_20180725.glf
│   │   │   └── 18LX_20180725.pressure 
│   ├── tag_label                         # labelization generated for and from TRAINSET
│   │   ├── 18LX-labeled.csv
│   │   └── 18LX.csv               
│   ├── twilight_label                          # labelization generated for and from TRAINSET
│   │   ├── 18LX-labeled.csv
│   │   └── 18LX.csv
│   └── wind                         # Data generated with analyis/3-static.R
│       └── 18LX
│           ├── 18LX_1.nc
│           └── ...
├── analysis                                # R code used to analyse your data. Follow the order
│   ├── 1-label.qmd
│   ├── 2-twilight.qmd
│   ├── 3-wind.qmd
│   ├── 4-geopressure.R
│   └── 5-create_figures.R
└── output                                 # Generate HTML report to be shared (see below for details)
    ├── _basic_trajectory.Rmd
    ├── _site.yml
    ├── _technical_details.Rmd
    ├── basic_trajectory
    │   └── 18LX.html
    ├── technical_details
    │   └── 18LX.html
    ├── index.Rmd
    └── make_reports.R
```

## :bulb: Where to start? 

### :hammer_and_wrench: Create your project 

**Option 1: with a github repository (recommended)**

![image](https://github.com/Rafnuss/GeoPressureTemplate/assets/7571260/09e6f2a5-e49c-439c-88ef-b1a84da7eb57)

- Create your project repo by clicking on "[Use this template](https://github.com/Rafnuss/GeoPressureTemplate/generate)" button on the Github page.
- Choose a project name (`my_tracking_study_name`) specific to your research. Note that `my_tracking_study_name`  will become the name of your folder on your computer too. Add a description of your study.
- Clone the repository on your computer
- Done! :tada:

**Option 2: without a github repository**

![image](https://github.com/Rafnuss/GeoPressureTemplate/assets/7571260/93e9f230-273d-4b45-acda-4a1e6443cf42)

- Download the code as a zip by clicking on [Code and Download ZIP](https://github.com/Rafnuss/GeoPressureTemplate/archive/refs/heads/v3.zip)
- Unzip and rename the folder name to your own project name.
- Done! :tada:


### :house: Make yourself at home 

- Rename `GeoPressureTemplate.Rproj` to your study name (e.g., `my_tracking_study_name.Rproj`).
- Edit the `DESCRIPTION` file (see <https://r-pkgs.org/description.html> for details).
- Delete the content of `README.md` and start writing your research objectives, describing your basic data, method etc.
- Install the dependencies needed with
```
devtools::install()
```
- Replace the content of `data/` with your tag data
- Optionally, modify the `LICENCES.md` file (see <https://r-pkgs.org/license.html> for details).

## :chart_with_upwards_trend: Analyse the data 

Now that you are set-up, it's time to start the serious work. :grimacing: Follow the order of the `.R` code in the `analysis/` folder. They follow the same order as the GeoPressureManual (but with different numeration to be able to analyse multiple track at the same time).

### 1. Tag label

`1-label.qmd` 

https://raphaelnussbaumer.com/GeoPressureManual/labelling-tracks.html#four-steps-to-check-labelling


### 2. Twilight label (optional)

### 3. Wind (optional

### 4. GeoPressure
  
|parameter          |example/default          |description                                                                                                            |
|-------------------|-------------------------|-----------------------------------------------------------------------------------------------------------------------|
|gdl_id             |18LX                     |Track identifier, used to read the raw file in the folder with this name (see [directory structure](https://github.com/Rafnuss/GeoPressureTemplate#project-structure-file_folder)).                                              |
|crop_start         |2017-06-20               |see [`tag_read()`](https://raphaelnussbaumer.com/GeoPressureR/reference/tag_read.html)                                 |
|crop_end           |2018-05-02               |see [`tag_read()`](https://raphaelnussbaumer.com/GeoPressureR/reference/tag_read.html)                                 |
|thr_dur            |12                       |Ignore stationary periods shorter than `thr_dur` (in hours). For complex track, start with high value 24-48 and work your way down to 0 until the labelization is done correctly.                                                                                                                         |
|extent_N           |50                       |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|extent_W           |-16                      |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|extent_S           |0                        |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|extent_E           |23                       |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|map_scale          |5                        |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|map_max_sample     |300                      |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|map_margin         |30                       |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|prob_map_s         |1                        |see [`geopressure_prob_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_prob_map.html)         |
|prob_map_s_calib   |                         |Alternative value for  `prob_map_s` for calibration site. Useful for species living in mountain only during calibration. |
|prob_map_thr       |0.9                      |see [`geopressure_prob_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_prob_map.html)         |
|twl_offset            |0                        |see [`find_twilights()`](https://raphaelnussbaumer.com/GeoPressureR/reference/find_twilights.html)                     |
|kernel_adjust      |1.4                      |see [Calibration of light data](https://raphaelnussbaumer.com/GeoPressureManual/light-map.html#calibrate-zenith-angles)        |
|calib_lon          |17.05                    |Longitude of the calibration site.                                                                                     |
|calib_lat          |48.9                     |Latitude of the calibration site.                                                                                      |
|calib_1_start      |2017-06-20               |Start date of the first calibration period.                                                                             |
|calib_1_end        |2017-08-05               |End date of the first calibration period.                                                                               |
|calib_2_start      |                         |Start date of the second calibration period.                                                                           |
|calib_2_end        |                         |End date of the second calibration period                                                                              |
|calib_2_lon        |                         |Longitude of the second calibration site (only use if different than first calibration site).                           |
|calib_2_lat        |                         |Latitude of the second calibration site (only use if different than first calibration site).                            |
|prob_light_w       |0.1                      |see [Probability map of light data](https://raphaelnussbaumer.com/GeoPressureManual/light-map.html#compute-probability-map)|
|thr_prob_percentile|0.9                      |see [`graph_create()`](https://raphaelnussbaumer.com/GeoPressureR/reference/graph_create.html)                         |
|thr_gs             |120                      |see [`graph_create()`](https://raphaelnussbaumer.com/GeoPressureR/reference/graph_create.html)                         |
|thr_as             |100                      |see [`graph_add_wind()`](https://raphaelnussbaumer.com/GeoPressureR/reference/graph_add_wind.html)                     |
|low_speed_fix      |15                       |see [`flight_prob()`](https://raphaelnussbaumer.com/GeoPressureR/reference/flight_prob.html)                           |
|scientific_name    |Acrocephalus arundinaceus|see [`flight_bird()`](https://raphaelnussbaumer.com/GeoPressureR/reference/flight_bird.html)                           |
|common_name        |Great Reed Warbler       |                                                                                                                       |
|mass               |                         |see [`flight_bird()`](https://raphaelnussbaumer.com/GeoPressureR/reference/flight_bird.html)                           |
|wing_span          |                         |see [`flight_bird()`](https://raphaelnussbaumer.com/GeoPressureR/reference/flight_bird.html)                           |


## Generate Report :page_facing_up:

Using the data generated, you can produce standardized reports in html and serve them on your github page repository. 
You can access the demo for 18LX at https://raphaelnussbaumer.com/GeoPressureTemplate/.

The main idea is to produce report templates (`_name_of_the_report_template.Rmd`) which can be used for multiple tracks at once. We generate the HTML page for each tracks-reports separately and puts them together into a website which can be serve on Github Page (and accessible for anyone!).

1. Developed your report template. Start from an existing one and change `gdl_id: "18LX"` to your species. You can visualize the output by [clicking the `knit` button in Rstudio](https://rmarkdown.rstudio.com/authoring_quick_tour.html).
2. Edit the website configuration file `_site.yml`. (Search online if you need help)
3. Look at `make_reports.R` script to see how you can generate the HTML for multiple tracks and reports templates at once. 
4. Edit `index.Rmd` as you wishes
5. Run `{r} render_site('./reports')` (also provided at the bottom of  `make_reports.R`) to generate the full website in `docs/`.
6. Push your changes on Github and create your [Github Page](https://rstudio.github.io/distill/publish_website.html#github-pages).


## Publication

For peer-review publication, it is essential that the data and code are accessible to reviewer. Because inaccurate labeling can lead to wrong trajectory, we highly encourage you to publish your data and code on Zenodo. This is made very easy using this github repository and [this guide](https://docs.github.com/en/repositories/archiving-a-github-repository/referencing-and-citing-content). This process will generate a DOI for your data and code which can be used in your repository. Here is an ey (e.g., <https://zenodo.org/record/7471405>)


## :link: Advanced options 
- Generate a citation file with [`usethis::use_citation`](https://usethis.r-lib.org/reference/use_citation.html) and [`cffr`](https://github.com/ropensci/cffr).
- Use [`renv`](https://rstudio.github.io/renv/index.html) to make your work reproducible.
