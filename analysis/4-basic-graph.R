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
  load(paste0("data/2_light/", gdl, "_light_prob.Rdata"))
  geopressureviz(
    pam = pam,
    static_prob = static_prob,
    static_prob_marginal = static_prob_marginal,
    pressure_prob = pressure_prob,
    light_prob = light_prob,
    pressure_timeserie = shortest_path_timeserie
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
