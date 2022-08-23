library(GeoPressureR)

# Define which track to work with
gdl <- "18LX"

# Load
load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))

# Create graph
grl <- graph_create(static_prob,
  thr_prob_percentile = gpr$thr_prob_percentile,
  thr_gs = gpr$thr_gs # threshold km/h
)

# Add wind
filename <- paste0("data/5_wind_graph/", gdl, "/", gdl, "_")
grl <- graph_add_wind(grl,
  pressure = pam$pressure, filename,
  thr_as = gpr$thr_as
)

save(grl,
  file = paste0("data/5_wind_graph/", gdl, "_grl.Rdata")
)
