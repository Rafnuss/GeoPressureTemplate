# GeoPressureTemplate

Analysing geolocator data with pressure is full of potential, but the the path is long and the journey can be challenging. `GeoPressureTemplate` is a [Github repository template](https://docs.github.com/articles/creating-a-repository-from-a-template/) for a startup R project to make that journey easier.

## What is this template and who is it for? :mag_right:

`GeoPressureTemplate` aims to help researchers analyse their geolocator data with [`GeoPressureR`](https://raphaelnussbaumer.com/GeoPressureR/). It provides the backbone R code containing the folder structure and code to correctly label your data and produce basic trajectory figures. 

In essence, it contains the code from all the [GeoPressureManual](https://raphaelnussbaumer.com/GeoPressureManual) packaged in an `.R` file to make it easy for you to apply it to your own data. 

## What do you need to use this template? :computer:

- Geolocator data containing pressure, light and activity data.
- Have read the [GeoPressureManual](https://raphaelnussbaumer.com/GeoPressureManual) (:warning: You should be familar with the **full process involved** before starting with your own project)
- Basic R experience (I'm using the [tidyverse](https://www.tidyverse.org/) syntax here).
- A [Github account](https://github.com/signup).


## Project structure :file_folder:

Following the recommendations of [rrrpkg](https://github.com/ropensci/rrrpkg), the project contains:
1. Standard description files at the root (`DESCRIPTION`, `.Rproj`, `README.md`, `LICENCES`,...).
2. `data/` folder containing the raw geolocator data, the pressure and light labelled files and the data generated with the code from `analysis/`. Note that you could instead keep the geolocator and labelization files seperately in a `raw-data/` folder, following `usethis()` standard.
3. `analysis/` contains all the `.R` code used for your project.
4. `report/` reads the data generated and produces sharable results (figures, html page, manuscript, etc...).
<details>
  <summary>See directory tree</summary>

```
GeoPressureTemplate
├── DESCRIPTION          		                # project metadata and dependencies
├── README.md            		                # top-level description of content and guide to users
├── GeoPressureTemplate.Rproj               # R project file
├── data                                    # Folder structured by order of use
│   ├── 0_PAM                               # Folder with raw geolocator data grouped by gdl_id
│   │   ├── 18LX
│   │   │   ├── 18LX_20180725.acceleration
│   │   │   ├── 18LX_20180725.glf
│   │   │   ├── 18LX_20180725.pressure 
│   │   │   └── ...
│   │   └── 22BT
│   │       └── ...
│   ├── 1_pressure                          # Data generated with analyis/1-pressure.R
│   │   ├── 18LX_pressure_prob.Rdata
│   │   └── labels
│   │       ├── 18LX_act_pres-labeled.csv
│   │       ├── 18LX_act_pres.csv
│   │       └── ...                    
│   ├── 2_light                             # Data generated with analyis/2-light.R
│   │   ├── 18LX_light_prob.Rdata
│   │   └── labels
│   │       ├── 18LX_light-labeled.csv
│   │       ├── 18LX_light.csv
│   │       └── ...    
│   ├── 3_static                            # Data generated with analyis/3-static.R
│   │   ├── 18LX_static_prob.Rdata
│   │   └── ...
│   ├── 4_basic_graph                       # Data generated with analyis/3-basic_graph.R
│   │   ├── 18LX_basic_graph.Rdata
│   │   └── ...
│   ├── 5_wind_graph
│   │   └── ERA5_wind
│   │       ├──
│   │       └── ...
│   └── gpr_settings.xlsx
├── analysis                                # R code used to analyse your data. Follow the order
│   ├── 1-pressure.R
│   ├── 2-light.R
│   ├── 3-static.R
│   ├── 4-basic-graph.R
│   ├── 5-1-wind-graph_download.R
│   ├── 5-2-wind-graph_create.R
│   ├── 5-3-wind-graph_analyse.R
│   └── 99-combined.R
└── reports                                 # Generate HTML report to be shared (see below for details)
│   ├── _basic_trajectory.Rmd
│   ├── _site.yml
│   ├── _technical_details.Rmd
│   ├── basic_trajectory
│   │   └── 18LX.html
│   ├── technical_details
│   │   └── 18LX.html
│   ├── index.Rmd
│   └── make_reports.R
└── docs                                      # Folder where your reports will be served as a website on Github Page
    └── ...
```
</details>

## Where to start? :bulb:

### Create your project 

- Create your project repo by clicking on "[Use this template](https://github.com/Rafnuss/GeoPressureTemplate/generate)" button on the Github page.
- Choose a project name (`my_tracking_study_name`) specific to your research. Note that `my_tracking_study_name`  will become the name of your folder on your computer too. Add a description of your study.
- Clone the repository on your computer
- Done! :tada:

### Make yourself at home :house:

- Rename `GeoPressureTemplate.Rproj` to `my_tracking_study_name.Rproj`.
- Open the R project file with RStudio. 
- Edit the `DESCRIPTION` file (see https://r-pkgs.org/description.html for details).
- Delete the content of `README.md` and start writing your research objectives, describing your basic data, method etc.
- Install the dependencies needed with

```
devtools::install()
```

- Delete the content of `data/` (but keep the directory tree). Put your PAM data in `data/0_PAM/` in a folder with the GDL_ID code (e.g. `data/0_PAM/18LX/`)


## Start analysing the data :chart_with_upwards_trend:

Now that you are set-up, it's time to start the serious work. :grimacing: Follow the order of the `.R` code in the `analysis/` folder. They follow the same order as the GeoPressureManual (but with different numerotation to be able to analyse multiple track at the same time).

|  GeoPressureTemplate analysis |  GeoPressureManual  |
|---|---|
|  `1-pressure.R`  |  [1. Pressure map](https://raphaelnussbaumer.com/GeoPressureManual/pressure-map.html) |
|  `2-light.R` |  [2. Light map](https://raphaelnussbaumer.com/GeoPressureManual/light-map.html) |
|  `3-static.R` | [3. Static map](https://raphaelnussbaumer.com/GeoPressureManual/static-map.html)  |
|  `4-basic-graph.R` |  [4. Basic graph](https://raphaelnussbaumer.com/GeoPressureManual/basic-graph.html) |
|  `5-1-wind-graph_graph_downloadt.R` |  [5. Wind graph - Download wind data](https://raphaelnussbaumer.com/GeoPressureManual/wind-graph.html#download-wind-data) |
|  `5-2-wind-graph_create.R` |  [5. Wind graph - Create graph](https://raphaelnussbaumer.com/GeoPressureManual/wind-graph.html#create-graph) |
|  `5-3-wind-graph_analyse.R` |  [5. Wind graph - Outputs](https://raphaelnussbaumer.com/GeoPressureManual/wind-graph.html#compute-the-transition-probability-1) |
|  `99-combined.R` |  Run all steps for multiple tracks. |

In order to keep your code clean, we isolate all the key paramters used in all functions in the `gpr_setting.xlsx` spreadsheet located in the `data/` folder. You can adjust these parameters seperatly for each track or add any informations on your individuals bird that might be useful for your analysis. 

<details>
  <summary>Click to see explanations on the parameters of <code>gpr_setting.xlsx</code></summary>
  
|parameter          |example/default          |description                                                                                                            |
|-------------------|-------------------------|-----------------------------------------------------------------------------------------------------------------------|
|gdl_id             |18LX                     |Track identifier, used to read the raw file in the folder with this name (see [directory structure](https://github.com/Rafnuss/GeoPressureTemplate#project-structure-file_folder)).                                              |
|crop_start         |2017-06-20               |see [`pam_read()`](https://raphaelnussbaumer.com/GeoPressureR/reference/pam_read.html)                                 |
|crop_end           |2018-05-02               |see [`pam_read()`](https://raphaelnussbaumer.com/GeoPressureR/reference/pam_read.html)                                 |
|thr_dur            |12                       |Ignore stationary periods shorter than `thr_dur` (in hours). For complex track, start with high value 24-48 and work your way down to 0 until the labelization is done correctly.                                                                                                                         |
|extent_N           |50                       |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|extent_W           |-16                      |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|extent_S           |0                        |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|extent_E           |23                       |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|map_scale          |5                        |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|map_max_sample     |300                      |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|map_margin         |30                       |see [`geopressure_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_map.html)                   |
|prob_map_s         |1                        |see [`geopressure_prob_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_prob_map.html)         |
|prob_map_s_calib   |                         |Alternative value for  `prob_map_s` for calibration site. Useful for species living in moutain only during calibration. |
|prob_map_thr       |0.9                      |see [`geopressure_prob_map()`](https://raphaelnussbaumer.com/GeoPressureR/reference/geopressure_prob_map.html)         |
|shift_k            |0                        |see [`find_twilights()`](https://raphaelnussbaumer.com/GeoPressureR/reference/find_twilights.html)                     |
|kernel_adjust      |1.4                      |see [Calibration of light data](https://raphaelnussbaumer.com/GeoPressureManual/light-map.html#calibrate-zenith-angles)        |
|calib_lon          |17.05                    |Longitude of the calibration site.                                                                                     |
|calib_lat          |48.9                     |Latitude of the calibrataion site.                                                                                      |
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
|ringNo             |                         |Ring number if available (not used).                                                                                                                        |
|scientific_name    |Acrocephalus arundinaceus|see [`flight_bird()`](https://raphaelnussbaumer.com/GeoPressureR/reference/flight_bird.html)                           |
|common_name        |Great Reed Warbler       |                                                                                                                       |
|mass               |                         |see [`flight_bird()`](https://raphaelnussbaumer.com/GeoPressureR/reference/flight_bird.html)                           |
|wing_span          |                         |see [`flight_bird()`](https://raphaelnussbaumer.com/GeoPressureR/reference/flight_bird.html)                           |

</details>

## Generate Report :page_facing_up:

Using the data generated, you can produce standardized reports in html and serve them on your github page repository. 
You can access the demo for 18LX at https://raphaelnussbaumer.com/GeoPressureTemplate/.

The main idea is to produce report templates (`_name_of_the_report_template.Rmd`) which can be used for multiple tracks at once. We generate the HTML page for each tracks-reports separately and puts them together into a website which can be serve on Github Page (and accessible for anyone!).

1. Developed your report template. Start from an existing one and change `gdl_id: "18LX"` to your species. You can visualize the output by [clicking the `knit` button in Rstudio](https://rmarkdown.rstudio.com/authoring_quick_tour.html).
2. Edit the website configuration file `_site.yml`. (Search online if you need help)
3. Look at `make_reports.R` script to see how you can generate the HTML for multiple tracks and reports templates at once. 
4. Edit `index.Rmd` as you wishes
5. Run `{r} render_site('./reports')` (also provided at the bottom of  `make_reports.R`) to generate the full website in `docs/`.
6. Push your changes on Gihub and create your [Github Page](https://rstudio.github.io/distill/publish_website.html#github-pages).


## Advanced options :link:

- Generate your DOI with [Zenodo](https://docs.github.com/en/repositories/archiving-a-github-repository/referencing-and-citing-content) (e.g., https://zenodo.org/record/6720386)
- Generate a citation file with [`usethis::use_citation`](https://usethis.r-lib.org/reference/use_citation.html) and [`cffr`](https://github.com/ropensci/cffr).
- Use [`renv`](https://rstudio.github.io/renv/index.html) to make your work reproducable.
- Export your data on [Movebank](https://www.movebank.org/cms/movebank-content/import-custom-tabular-data).
