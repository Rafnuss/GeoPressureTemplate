library(GeoPressureR)
library(leaflet)
library(leaflet.extras)
library(raster)
library(igraph)

# Define which track to work with
gdl <- "18LX"

debug <- T

# Load
load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))
load(paste0("data/5_wind_graph/", gdl, "_grl.Rdata"))

# Movement model
bird <- flight_bird(gpr$scientific_name)
speed <- seq(0, 80)
prob <- flight_prob(speed,
  method = "power", bird = bird, low_speed_fix = 20,
  fun_power = function(power) {
    (1 / power)^3
  }
)
plot(speed, prob, type = "l", xlab = "Airspeed [km/h]", ylab = "Probability")

# Convert to probability
grl$p <- grl$ps * flight_prob(grl$as, method = "power", bird = bird, low_speed_fix = 20)


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
nj <- 30
path_sim <- graph_simulation(grl, nj = nj)



if (debug) {

  # In depth analysis with GeoPressureViz
  load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
  load(paste0("data/2_light/", gdl, "_light_prob.Rdata"))
  load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))

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


# Save ----
save(
  path_sim,
  shortest_path,
  static_prob_marginal,
  shortest_path_timeserie,
  file = paste0("data/5_wind_graph/", gdl, "_wind_graph.Rdata")
)
