library(GeoPressureR)
library(leaflet)
library(leaflet.extras)
library(raster)
library(igraph)

debug <- T

# Define which track to work with
gdl <- "18LX"

# Load static prob
load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))

# Build the graph ----
grl <- graph_create(static_prob,
  thr_prob_percentile = gpr$thr_prob_percentile,
  thr_gs = gpr$thr_gs # threshold km/h
)
# If you get an error with trimming, use geopressureviz from end of 3.static.R

# Add probability of each edge
grl$p <- grl$ps * flight_prob(grl$gs, method = "gamma", shape = 7, scale = 7, low_speed_fix = gpr$low_speed_fix)









# Marginal map ----
static_prob_marginal <- graph_marginal(grl)


# Shortest path ----
g <- graph_from_data_frame(data.frame(
  from = grl$s,
  to = grl$t,
  weight = -log(grl$p)
))

retrieval <- which.max(as.matrix(static_prob_marginal[[length(static_prob_marginal)]])) + grl$sz[1] * grl$sz[2] * (grl$sz[3] - 1)
stopifnot(retrieval %in% grl$retrieval)
sp <- shortest_paths(g, from = paste(grl$equipment), to = paste(retrieval))

# Convert igraph representation to lat-lon
shortest_path <- graph_path2lonlat(as.numeric(sp$vpath[[1]]$name), grl)
shortest_path_df <- as.data.frame(shortest_path)
shortest_path_timeserie <- geopressure_ts_path(shortest_path_df, pam$pressure, include_flight = c(0, 1))

# Simulation ----
nj <- 10
path_sim <- graph_simulation(grl, nj = nj)



if (debug) {

  # Rapid visual check
  sta_duration <- unlist(lapply(static_prob_marginal, function(x) {
    as.numeric(difftime(metadata(x)$temporal_extent[2], metadata(x)$temporal_extent[1], units = "days"))
  }))

  m <- leaflet(width = "100%") %>%
    addProviderTiles(providers$Stamen.TerrainBackground) %>%
    addFullscreenControl()
  for (i in seq_len(nj)) {
    m <- m %>%
      addPolylines(lng = path_sim$lon[i, ], lat = path_sim$lat[i, ], opacity = 0.7, weight = 1, color = "#808080") %>%
      addCircles(lng = path_sim$lon[i, ], lat = path_sim$lat[i, ], opacity = 1, weight = 1, color = "#000")
  }

  m %>%
    addPolylines(lng = shortest_path$lon, lat = shortest_path$lat, opacity = 1, color = "#808080", weight = 3) %>%
    addCircles(lng = shortest_path$lon, lat = shortest_path$lat, opacity = 1, color = "#000", weight = sta_duration^(0.3) * 10)


  # Light comparison
  load(paste0("data/2_light/", gdl, "_light_prob.Rdata"))
  raw_geolight <- pam$light %>%
    transmute(
      Date = date,
      Light = obs
    )
  lightImage(
    tagdata = raw_geolight,
    offset = gpr$shift_k / 60 / 60
  )
  tsimagePoints(twl$twilight,
    offset = -gpr$shift_k / 60 / 60, pch = 16, cex = 1.2,
    col = ifelse(twl$deleted, "grey20", ifelse(twl$rise, "firebrick", "cornflowerblue"))
  )
  for (ts in shortest_path_timeserie) {
    twl_fl <- twl %>%
      filter(twilight > ts$date[1] & twilight < tail(ts$date, 1))
    tsimageDeploymentLines(twl_fl$twilight,
      lon = ts$lon[1], ts$lat[1],
      offset = gpr$shift_k / 60 / 60, lwd = 3, col = adjustcolor("orange", alpha.f = 0.5)
    )
  }

  # In depth analysis with GeoPressureViz
  load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
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
}


# Save
save( # grl, we are excluding grl because of its size on this repo. Feel free to keep it in your own project
  path_sim,
  shortest_path,
  static_prob_marginal,
  shortest_path_timeserie,
  file = paste0("data/4_basic_graph/", gpr$gdl_id, "_basic_graph.Rdata")
)
