library(tidyverse)
library(readxl)

gdl_list <- read_excel("data/gpr_settings.xlsx") %>%
  .$gdl_id

for (i in seq(1, length(gdl_list))) {
  gdl <- gdl_list[i]
  source("analysis/1-pressure.R")
  source("analysis/2-light.R")
  source("analysis/3-static.R")
  source("analysis/4-basic-graph.R")
}

## Check with GeoPressureViz
load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
load(paste0("data/2_light/", gdl, "_light_prob.Rdata"))
load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))
load(paste0("data/4_basic_graph/", gdl, "_basic_graph.Rdata"))

sta_static <- unlist(lapply(static_prob, function(x) raster::metadata(x)$sta_id))
sta_marginal <- unlist(lapply(static_prob_marginal, function(x) raster::metadata(x)$sta_id))
sta_pres <- unlist(lapply(pressure_prob, function(x) raster::metadata(x)$sta_id))
sta_light <- unlist(lapply(light_prob, function(x) raster::metadata(x)$sta_id))
pressure_prob <- pressure_prob[sta_pres %in% sta_marginal]
light_prob <- light_prob[sta_light %in% sta_marginal]

geopressureviz <- list(
  pam = pam,
  static_prob = static_prob,
  static_prob_marginal = static_prob_marginal,
  pressure_prob = pressure_prob,
  light_prob = light_prob,
  pressure_timeserie = shortest_path_timeserie
)
save(geopressureviz, file = "~/geopressureviz.RData")

shiny::runApp(system.file("geopressureviz", package = "GeoPressureR"),
  launch.browser = getOption("browser")
)



# Add Wind
dir.create("data/5_wind_graph", showWarnings = FALSE)
# Create the request
for (i in seq(1, length(gdl_list))) {
  gdl <- gdl_list[i]
  source("analysis/5-1-wind-graph_request.R")
}

# Download the file
for (i in seq(1, length(gdl_list))) {
  gdl <- gdl_list[i]
  source("analysis/5-2-wind-graph_transfer.R")
}

# delete the Rdata file of the request (only once download completed)
for (i in seq(1, length(gdl_list))) {
  gdl <- gdl_list[i]
  req_file <- paste0("data/5_wind_graph/", gdl, "_request.Rdata")
  if (file.exists(req_file)) {
    file.remove(req_file)
  }
}

# Create the graph with windspeed
for (i in seq(1, length(gdl_list))) {
  gdl <- gdl_list[i]
  source("analysis/5-3-wind-graph_create.R")
}

# Compute marginal, simulate path, shortest path
for (i in seq(1, length(gdl_list))) {
  gdl <- gdl_list[i]
  source("analysis/5-4-wind-graph_analyse.R")
}





# Update gpr ---
# If you modified some value in gpr_settings, you can update gpr with the following code
for (i in seq(1, length(gdl_list))) {
  gdl <- gdl_list[i]

  load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))

  gpr <- read_excel("data/gpr_settings.xlsx") %>%
    filter(gdl_id == gdl)

  save(
    pressure_timeserie, # can be removed in not in debug mode
    pressure_prob,
    pam,
    gpr,
    file = paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata")
  )
}
