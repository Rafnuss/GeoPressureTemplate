# GeoPressureTemplate

Analysing geolocator data with pressure is full of potential, but the the path is long and the journey can be challenging. `GeoPressureTemplate` is a [Github repository template](https://docs.github.com/articles/creating-a-repository-from-a-template/) for a startup R project to make that journey easier.

## What is this template and who is it for? :mag_right:

`GeoPressureTemplate` aims to help researchers analyse their geolocator data with [`GeoPressureR`](https://raphaelnussbaumer.com/GeoPressureR/). It provides the backbone R code containing the folder structure and code to correctly label your data and produce basic trajectory figures. 

In essence, it contains the code from all the [GeoPressureR vignettes](https://raphaelnussbaumer.com/GeoPressureR/articles/) packaged in an `.R` file to make it easy for you to apply it to your own data. 

## What do you need to use this template? :computer:

- Geolocator data containing pressure, light and activity data.
- Have read the [GeoPressureR vignettes](https://raphaelnussbaumer.com/GeoPressureR/articles/) (:warning: You should be familar with the **full process involved** before starting with your own project)
- Basic R experience (I'm using the [tidyverse](https://www.tidyverse.org/) syntax here).
- A [Github account](https://github.com/signup).


## Project structure :file_folder:

Following the recommendations of [rrrpkg](https://github.com/ropensci/rrrpkg), the project contains:
1. Standard description files at the root (`DESCRIPTION`, `.Rproj`, `README.md`, `LICENCES`,...)
2. `data/` folder containing the raw geolocator data, the pressure and light labelled files and the data generated with the code from `analysis/`. Note that you could put the geolocator and labelization files in `raw-data`, following `usethis()` standard 
3. `analysis/` contains all the `.R` code used for your project
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
│   └── 5-wind-graph.R
└── reports                                 # Generate HTML report to be shared (see below for details)
│   ├── _basic_trajectory.Rmd
│   ├── _site.yml
│   ├── _technical_details.Rmd
│   ├── basic_trajectory
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
- Edit the `DESCRIPTION` file (see https://r-pkgs.org/description.html for details). Start the version to `0.0.1` or `0.1.0`.
- Delete the content of `README.md` and start writing your research objectives, describing your basic data, method etc.
- Install the dependencies needed with

```
devtools::install()
```

- Delete the content of `data/` (but keep the directory tree). Put your PAM data in `data/0_PAM/` in a folder with the GDL_ID code (e.g. `data/0_PAM/18LX/`)
- Enter the information you already have about your track in the `gpr_setting.xlsx` spreadsheet. You can add new columns if needed.

## Start analysing the data :chart_with_upwards_trend:

Now that you are set-up, it's time to start the serious work. :grimacing: Follow the order of the `.R` code in the `analysis/` folder. They follow the same order as the vignettes (but with different numerotation).

|  GeoPressureTemplate analysis |  GeoPressureR vignettes  |
|---|---|
|  `1-pressure.R`  |  [Creating probability maps from pressure data](https://raphaelnussbaumer.com/GeoPressureR/articles/pressure-map.html) |
|  `2-light.R` |  [Creating probability maps from light data](https://raphaelnussbaumer.com/GeoPressureR/articles/light-map.html) |
|  `3-static.R` | [Preparing data for trajectory modelling](https://raphaelnussbaumer.com/GeoPressureR/articles/preparing-data.html)  |
|  `4-basic-graph.R` |  [Modeling trajectory with a graph](https://raphaelnussbaumer.com/GeoPressureR/articles/basic-graph.html) |


## Generate Report :page_facing_up:

Using the data generated, you can produce standardized reports in html and serve them on your github page repository. 
You can access the demo for 18LX at [https://raphaelnussbaumer.com/GeoPressureTemplate/].

The main idea is to produce report templates (`_name_of_the_report_template.Rmd`) which can be used for multiple tracks at once. We generate the HTML page for each tracks-reports separatly and puts them together into a website which can be serve on Github Page (and accessible for anywone!).

1. Developed your report template. Start from an exisitng one and change `gdl_id: "18LX"` to your species. You can visualize the output by [clicking the `knit` button in Rstudio](https://rmarkdown.rstudio.com/authoring_quick_tour.html).
2. Edit the website configuration file `_site.yml`. (Search online if you need help)
3. Look at `make_reports.R` script to see how you can generate the HTML for multiple tracks and reports templates at once. 
4. Edit `index.Rmd` as you wishes
5. Run `{r} render_site('./reports')` (also provided at the bottom of  `make_reports.R`) to generate the full website in `docs/`.
6. Push your changes on Gihub and create your [Github Page](https://rstudio.github.io/distill/publish_website.html#github-pages).


## Advanced options :link:

- Generate your DOI with [Zenodo](https://zenodo.org/).
- Generate a citation file with [`usethis::use_citation`](https://usethis.r-lib.org/reference/use_citation.html) and [`cffr`](https://github.com/ropensci/cffr).
- Use [`renv`](https://rstudio.github.io/renv/index.html) to make your work reproducable.
- Export your data on [Movebank](https://www.movebank.org/cms/movebank-content/import-custom-tabular-data).
