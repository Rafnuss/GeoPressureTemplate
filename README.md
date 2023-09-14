# GeoPressureTemplate

Analyzing geolocator data with [GeoPressureR](https://raphaelnussbaumer.com/GeoPressureR/) is full of potential, but the the path is long and the journey can be challenging. `GeoPressureTemplate` provides a start-up R project to make that journey easier.

This [Github repository template](https://docs.github.com/articles/creating-a-repository-from-a-template/) contains a standard project folder structure and R script to store your data, analyse it, and produce outputs.

:warning: To use this template, you must be familiar with the **full GeoPressureR workflow**, described in the [GeoPressureManual](https://raphaelnussbaumer.com/GeoPressureManual).

## :file_folder: Project structure

We defined a standardized project folder structure based on a mix of [rrrpkg](https://github.com/ropensci/rrrpkg#getting-started-with-a-research-compendium), [rrtools](https://github.com/benmarwick/rrtools#4-rrtoolsuse_analysis) and [cookiecutter data science](http://drivendata.github.io/cookiecutter-data-science/#directory-structure).


```         
GeoPressureTemplate/
├── DESCRIPTION                             # Project metadata and dependencies
├── README.md                               # Top-level description of content and guide to users
├── GeoPressureTemplate.Rproj               # R project file
├── LICENCES.md                             # Conditions of re/use the data and code
├── config.yml                              # YML file used to defined the parameters used in the analysis
├── data/                                 
│   ├── raw_tag/                            # Raw geolocator data (do not modify!)
│   │   ├── 18LX/
│   │   │   ├── 18LX_20180725.acceleration
│   │   │   ├── 18LX_20180725.glf
│   │   │   └── 18LX_20180725.pressure 
│   │   └── CB619/ 
│   │       └── CB619.deg
│   ├── tag_label/                          # Trainset csv file generated with analyis/1-label.qmd
│   │   ├── 18LX-labeled.csv
│   │   ├── 18LX.csv 
│   │   ├── CB619-labeled.csv
│   │   └── CB619.csv            
│   ├── twilight_label/                     # Trainset csv file generated with analyis/2-twilight.qmd
│   │   ├── 18LX-labeled.csv
│   │   └── 18LX.csv
│   ├── wind/                                # ERA-5 wind data generated with analyis/3-wind.qmd
│   │   └── 18LX/
│   │       ├── 18LX_1.nc
│   │       └── ...
│   └── interim/                             # Intermediate data, typically .RData or .Rds
│       └── 18LX.RData                      
├── analysis/                                # R code used to analyse your data.
│   ├── 1-label.qmd
│   ├── 2-twilight.qmd
│   ├── 3-wind.qmd
│   ├── 4-geopressure.R
└── output/   
    ├── create_figures.R
    ├── figures/
        └── dfdf.png
    └── create_figures.R
```

## :bulb: Get started

### :hammer_and_wrench: Create your project

**Option 1: with a Github repository (recommended)**

-   Create your project repo by clicking on the green button "[Use this template](https://github.com/Rafnuss/GeoPressureTemplate/generate)".
-   Choose a project name (e.g., `my_tracking_study_name`) specific to your research. Note that this will become the name of your folder on your computer too.
-   Clone the repository on your computer.
-   Done! :tada:

**Option 2: without a Github repository**

-   Download the repo by clicking on the green button [Code and Download ZIP](https://github.com/Rafnuss/GeoPressureTemplate/archive/refs/heads/v3.zip)
-   Unzip and rename the folder name to your own project name.
-   Done! :tada:

### :house: Make yourself at home

1.  Rename `GeoPressureTemplate.Rproj` to your study name (e.g., `my_tracking_study_name.Rproj`). You can now open the project on RStudio. 
2.  Edit the `DESCRIPTION` file (see <https://r-pkgs.org/description.html> for details).
3.  Delete the content of `README.md` and write your research objectives, describing your basic data, method etc.
4.  Replace the content of `data/` with your tag data.
5.  Install the dependencies needed with

```{r}
devtools::install()
```
6.  Optionally, modify the `LICENCES.md` file (see <https://r-pkgs.org/license.html> for details).


## What is the `config.yml` file?

Before jumping into the analysis, we need to introduce `config.yml`. It's a [YAML file](https://en.wikipedia.org/wiki/YAML) which defines the parameters used in the analysis. Separating these parameters from the main code follows best practices in terms of reproducibility, readability, and sharability. We use the [config R package](https://rstudio.github.io/config/) to retrieve the parameter values in the code with,

```{r}
config::get("crop_start", config = "18LX") # "2017-06-20"
```

One advantage of this file is the ability to define a default set of parameters (i.e. valid for all tags), as well as specific parameters for each tag.

```{r}
config::get("thr_gs", config = "18LX") # 150
```

## :chart_with_upwards_trend: Analyse the data

Now that you are set up, it's time to get serious :grimacing:

### Step 1: Preparation

In this first step, we will make sure everything is ready to run the model. This involves setting up the parameters in `config.yml` while running the following three scripts:

1.  Run `1-label.qmd` 
2.  (optional) `2-twilight.qmd`
3.  (optional) `3-wind.qmd`

While doing so, please keep in mind:
- Nothing is saved at the end of the script (and that's how it's supposed to be!). Only label files and `config.yml` should be edited. 
- The scripts should be run successively for each tag separately
- We use [quarto script](https://quarto.org/) to make it easy to run chunks based on your needs (e.g., re-run a small chunk after making a change). The scripts are not meant to be run with "Run all".
- These scripts should be adapted based on your project, but the same script should run for all your tags.


### Step 2: Compute the trajectory

The main script is `4-geopressure.R`

### Step 3: Your own analyis


## Publication 

For peer-review publication, it is essential that the data and code are accessible to reviewer. Because inaccurate labeling can lead to wrong trajectory, we highly encourage you to publish your data and code on Zenodo. This is made very easy using this github repository and [this guide](https://docs.github.com/en/repositories/archiving-a-github-repository/referencing-and-citing-content). This process will generate a DOI for your data and code which can be used in your repository. Here is an ey (e.g., <https://zenodo.org/record/7471405>)

What it needs to include:

## :link: Advanced options

-   Generate a citation file with [`usethis::use_citation`](https://usethis.r-lib.org/reference/use_citation.html) and [`cffr`](https://github.com/ropensci/cffr).
-   Use [`renv`](https://rstudio.github.io/renv/index.html) to make your work reproducible.

### Generate Report :page_facing_up:

Using the data generated, you can produce standardized reports in html and serve them on your github page repository. You can access the demo for 18LX at <https://raphaelnussbaumer.com/GeoPressureTemplate/>.

The main idea is to produce report templates (`_name_of_the_report_template.Rmd`) which can be used for multiple tracks at once. We generate the HTML page for each tracks-reports separately and puts them together into a website which can be serve on Github Page (and accessible for anyone!).

1.  Developed your report template. Start from an existing one and change `gdl_id: "18LX"` to your species. You can visualize the output by [clicking the `knit` button in Rstudio](https://rmarkdown.rstudio.com/authoring_quick_tour.html).
2.  Edit the website configuration file `_site.yml`. (Search online if you need help)
3.  Look at `make_reports.R` script to see how you can generate the HTML for multiple tracks and reports templates at once.
4.  Edit `index.Rmd` as you wishes
5.  Run `{r} render_site('./reports')` (also provided at the bottom of `make_reports.R`) to generate the full website in `docs/`.
6.  Push your changes on Github and create your [Github Page](https://rstudio.github.io/distill/publish_website.html#github-pages).

