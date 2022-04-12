library(GeoPressureR)
library(leaflet)
library(leaflet.extras)
library(raster)
library(igraph)

# Define which track to work with
gdl <- "18LX"

# Load static prob
load(paste0("data/5_static_prob/", gdl, "_static_prob.Rdata"))

# Build the graph ----
grl <- graph_create(static_prob,
  thr_prob_percentile = .99,
  thr_gs = 150 # threshold km/h
)

# If you get an error with trimming. You can start GeoPressureViz
if (FALSE) {
  load(paste0("data/3_pressure_prob/", gdl, "_pressure_prob.Rdata"))
  load(paste0("data/4_light_prob/", gdl, "_light_prob.Rdata"))
  sta_static <- unlist(lapply(static_prob, function(x) raster::metadata(x)$sta_id))
  sta_pres <- unlist(lapply(pressure_prob, function(x) raster::metadata(x)$sta_id))
  sta_light <- unlist(lapply(light_prob, function(x) raster::metadata(x)$sta_id))
  pressure_prob <- pressure_prob[sta_pres %in% sta_static]
  light_prob <- light_prob[sta_light %in% sta_static]


  geopressureviz <- list(
    pam_data = pam,
    static_prob = static_prob,
    pressure_prob = pressure_prob,
    light_prob = light_prob,
    pressure_timeserie = static_timeserie
  )
  save(geopressureviz, file = "~/geopressureviz.RData")

  shiny::runApp(system.file("geopressureviz", package = "GeoPressureR"),
    launch.browser = getOption("browser")
  )
}


# Add probability of each edge
grl$p <- grl$ps * flight_prob(grl$gs, method = "gamma", shape = 7, scale = 7)









# Marginal map ----
static_prob_marginal <- graph_marginal(grl)


# Shortest path ----
g <- graph_from_data_frame(data.frame(
  from = grl$s,
  to = grl$t,
  weight = -log(grl$p)
))

retrival <- which.max(as.matrix(static_prob_marginal[[length(static_prob_marginal)]])) + grl$sz[1] * grl$sz[2] * (grl$sz[3] - 1)
stopifnot(retrival %in% grl$retrival)
sp <- shortest_paths(g, from = paste(grl$equipement), to = paste(retrival))

# Convert igraph representation to lat-lon
grl$shortest_path <- graph_path2lonlat(as.numeric(sp$vpath[[1]]$name), grl)


# Simulation ----
nj <- 10
path_sim <- graph_simulation(grl, nj = nj)




# Rapid visual check

sta_duration <- unlist(lapply(static_prob_marginal, function(x) {
  as.numeric(difftime(metadata(x)$temporal_extent[2], metadata(x)$temporal_extent[1], units = "days"))
}))

m <- leaflet(width = "100%") %>%
  addProviderTiles(providers$Stamen.TerrainBackground) %>%
  addFullscreenControl() %>%
  addPolylines(lng = grl$shortest_path$lon, lat = grl$shortest_path$lat, opacity = 1, color = "#808080", weight = 3) %>%
  addCircles(lng = grl$shortest_path$lon, lat = grl$shortest_path$lat, opacity = 1, color = "#000", weight = sta_duration^(0.3) * 10)

for (i in seq_len(nj)) {
  m <- m %>%
    addPolylines(lng = path_sim$lon[i, ], lat = path_sim$lat[i, ], opacity = 0.7, weight = 1, color = "#808080") %>%
    addCircles(lng = path_sim$lon[i, ], lat = path_sim$lat[i, ], opacity = 1, weight = 1, color = "#000")
}

m



# In depth analysis with GeoPressureViz
load(paste0("data/3_pressure_prob/", gdl, "_pressure_prob.Rdata"))
load(paste0("data/4_light_prob/", gdl, "_light_prob.Rdata"))
sta_marginal <- unlist(lapply(static_prob_marginal, function(x) raster::metadata(x)$sta_id))
sta_pres <- unlist(lapply(pressure_prob, function(x) raster::metadata(x)$sta_id))
sta_light <- unlist(lapply(light_prob, function(x) raster::metadata(x)$sta_id))
pressure_prob <- pressure_prob[sta_pres %in% sta_marginal]
light_prob <- light_prob[sta_light %in% sta_marginal]

shortest_path <- as.data.frame(grl$shortest_path)
shortest_path_timeserie <- geopressure_ts_path(shortest_path, pam$pressure)


geopressureviz <- list(
  pam_data = pam,
  static_prob = static_prob_marginal,
  pressure_prob = pressure_prob,
  light_prob = light_prob,
  pressure_timeserie = shortest_path_timeserie
)
save(geopressureviz, file = "~/geopressureviz.RData")

shiny::runApp(system.file("geopressureviz", package = "GeoPressureR"),
  launch.browser = getOption("browser")
)


# Save
save(grl,
  path_sim,
  static_prob_marginal,
  shortest_path_timeserie,
  file = paste0("data/6_basic_graph/", set$gdl_id, "_basic_graph.Rdata")
)
