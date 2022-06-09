library(GeoPressureR)

# Define which track to work with
gdl <- "18LX"

# Load
load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))

# Create graph
grl <- graph_create(static_prob, thr_prob_percentile = .99, thr_gs = 100)

# Add wind
filename = paste0("data/5_wind_graph/",gdl,"/",gdl,"_")
grl <- graph_add_wind(grl, pressure=pam$pressure, filename, thr_as = 100)

# Movement model
bird <- flight_bird()
speed <- seq(0,80)
prob <- flight_prob(speed, method = "power", bird = bird, low_speed_fix = 10,
                    fun_power = function(power) { (1 / power)^3 })
plot(speed, prob, type="l", xlab="Airspeed [km/h]", ylab="Probability")
