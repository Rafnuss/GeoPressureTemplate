# GeoPressureTemplate

Analysing geolocator data with pressure is full of potential, but the the path is long and the journey is dificult. `GeoPressureTemplate` is a [Github reposiotry template](https://docs.github.com/articles/creating-a-repository-from-a-template/) for a startup R project to help you make that journey more easy.

## What is this template and how is it address for?

`GeoPressureTemplate` aims to help researcher to start analyse their geolocator data with [`GeoPressureR`](https://raphaelnussbaumer.com/GeoPressureR/). It provides you with the backbone R code containing the folder structure and code to label correctly your data and produce basic trajectory figure. 

In essence, it contains the code from all [GeoPressureR vignettes](https://raphaelnussbaumer.com/GeoPressureR/articles/) written in `.R` file to make if easier for you to apply your own data. 

## What do you need to use this template?

- Have gelocator data containing pressure, light and activity data.
- Have read the [GeoPressureR vignettes](https://raphaelnussbaumer.com/GeoPressureR/articles/) (:warning: You really need to be familar with the full process involved before starting with your own project)
- Some basic R experience. 
- A Github account


## Structure of this project

Following the recommendation of [rrrpkg](https://github.com/ropensci/rrrpkg), we structure the project with:
- Standard description files at the root (`DESCRIPTION`, `.Rproj`, `README.md`, `LICENCES`,...)
- `data/` containing the raw geolocator data, the pressure and light labeled file and the data generated with the code from `analysis/`. Note that you could put the geolocator and labelization file in a `raw-data`, following `usethis()` standard. 
- `analysis/` contains all the `.R` code used by your project.
- `report/` reads the data generated and produce sharable result (figures, html page, manuscript etc...)
<details>
  <summary>See directory tree</summary>

```
GeoPressureTemplate
├── DESCRIPTION          		# project metadata and dependencies
├── README.md            		# top-level description of content and guide to users
├── GeoPressureTemplate.Rproj    # R project file
├── data
│   ├── 0_PAM
│   │   ├── 18LX
│   │   │   ├── 18LX_20180725.acceleration
│   │   │   ├── 18LX_20180725.data
│   │   │   ├── 18LX_20180725.glf
│   │   │   ├── 18LX_20180725.log
│   │   │   ├── 18LX_20180725.magnetic
│   │   │   ├── 18LX_20180725.pressure 
│   │   │   └── 18LX_20180725.settings
│   │   └── 22BT
│   │       └── ...
│   ├── 1_act_pres_labels
│   │   ├── 18LX_act_pres-labeled.csv
│   │   ├── 18LX_act_pres.csv
│   │   ├── 22BT_act_pres-labeled.csv
│   │   ├── 22BT_act_pres.csv
│   │   └── ...
│   ├── 2_light_labels
│   │   ├── 18LX_light-labeled.csv
│   │   ├── 18LX_light.csv
│   │   ├── 22BT_light-labeled.csv
│   │   ├── 22BT_light.csv
│   │   └── ...
│   ├── 3_pressure_prob
│   │   ├── 18LX_pressure_prob.Rdata
│   │   ├── 22BT_pressure_prob.Rdata
│   │   └── ...
│   ├── 4_light_prob
│   │   ├── 18LX_light_prob.Rdata
│   │   ├── 22BT_light_prob.Rdata
│   │   └── ...
│   ├── 5_static_prob
│   │   ├── 18LX_static_prob.Rdata
│   │   ├── 22BT_static_prob.Rdata
│   │   └── ...
│   ├── 6_basic_graph
│   │   ├──	18LX_basic_prob.Rdata
│   │   ├── 22BT_basic_prob.Rdata
│   │   └── ...
│   ├── 7_wind_graph
│   │   ├──	18LX_wind_prob.Rdata
│   │   ├── 22BT_wind_prob.Rdata
│   │   └── ...
│   └── gdl_settings.xlsx
├── analysis
│   ├── 1-pressure.R
│   ├── 2-light.R
│   ├── 3-static.R
│   ├── 4-basic-graph.R
│   └── 5-wind-graph.R
└── report
    ├── 1-pressure.R
    ├── 2-light.R
    ├── 3-static.R
    ├── 4-basic-graph.R
    └── 99-combined.R
```
</details>

## Where to start ?

### Create your project

- Create your project repo by clicking on "[Use this template](https://github.com/Rafnuss/GeoPressureTemplate/generate)" button on the github page.
- Rename the project to something specific to your research. This will become the name of your folder on your computer. 
- Done!

### Make yourself at home

- Rename `GeoPressureTemplate.Rproj` to match the name for of your project.
- Edit the `DESCRIPTION` file (see https://r-pkgs.org/description.html for details)
- Delete the content of `README.md` and start writing your research objective, describe our basic data, method etc...
- Put your PAM data in `data/0_PAM/` in a folder with the GDL_ID code (e.g. `data/0_PAM/18LX/`)
- Write the information you already have about your track in the `gdl_setting.xlsx` spreadsheet. You can add new columns based on your bird equiped.

## Start analysing the data

Now that you are set-up, it's time to start the serious work. Follow the order of the `.R` code in the `analysis/` folder. They follow the same order than the vignettes (but with different enumeration).

|  GeoPressureTemplate analysis |  GeoPressureR vignettes  |
|---|---|
|  `1-pressure.R`  |  [Creating probability maps from pressure data](https://raphaelnussbaumer.com/GeoPressureR/articles/pressure-map.html) |
|  `2-light.R` |  [Creating probability maps from light data](https://raphaelnussbaumer.com/GeoPressureR/articles/light-map.html) |
|  `3-static.R` | [Preparing data for trajectory modelling](https://raphaelnussbaumer.com/GeoPressureR/articles/preparing-data.html)  |
|  `4-basic-graph.R` |  [Modeling trajectory with a graph](https://raphaelnussbaumer.com/GeoPressureR/articles/basic-graph.html) |


## Generate Report



## Advence options

- Generate DOI with [Zenodo](https://zenodo.org/).
- Generate citation file with [`usethis::use_citation`](https://usethis.r-lib.org/reference/use_citation.html) and [`cffr`](https://github.com/ropensci/cffr)
- Use [`renv`](https://rstudio.github.io/renv/index.html) to make your work reproducable.
- Export your data on [Movebank](https://www.movebank.org/cms/movebank-content/import-custom-tabular-data).