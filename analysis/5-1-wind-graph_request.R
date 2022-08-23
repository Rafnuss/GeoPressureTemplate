library(ecmwfr)

# Define which track to work with
gdl <- "18LX"

# Load
load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))

# Set credential
# Sys.setenv( cds.key="Insert_your_CDS_API_KEY_here")
# Sys.setenv( cds.user="Insert_your_CDS_UID_here")
cds.key <- Sys.getenv("cds.key")
cds.user <- Sys.getenv("cds.user")
wf_set_key(user = cds.user, key = cds.key, service = "cds")


possible_pressure <- c(1, 2, 3, 5, 7, 10, 20, 30, 50, 70, seq(100, 250, 25), seq(300, 750, 50), seq(775, 1000, 25))
area <- raster::extent(static_prob[[1]])
area <- c(area@ymax, area@xmin, area@ymin, area@xmax)

req <- list()
for (i_s in seq(1, nrow(pam$sta) - 1)) {
  # Get the timeserie of the flight on a 1 hour resolution
  flight_time <- seq(round(pam$sta$end[i_s] - 30 * 60, units = "hours"), round(pam$sta$start[i_s + 1] + 30 * 60, units = "hours"), by = 60 * 60)

  # Find the pressure level needed during this flight
  flight_id <- flight_time[1] <= pam$pressure$date & pam$pressure$date <= tail(flight_time, 1)
  pres_id_min <- sum(!(min(pam$pressure$obs[flight_id]) < possible_pressure))
  pres_id_max <- sum(max(pam$pressure$obs[flight_id]) > possible_pressure) + 1
  flight_pres_id <- seq(pres_id_min, min(pres_id_max, length(possible_pressure)))

  # Prepare the query
  request <- list(
    dataset_short_name = "reanalysis-era5-pressure-levels",
    product_type = "reanalysis",
    format = "netcdf",
    variable = c("u_component_of_wind", "v_component_of_wind"),
    pressure_level = possible_pressure[flight_pres_id],
    year = sort(unique(format(flight_time, "%Y"))),
    month = sort(unique(format(flight_time, "%m"))),
    day = sort(unique(format(flight_time, "%d"))),
    time = sort(unique(format(flight_time, "%H:%M"))),
    area = area
  )
  # We can send the query without downloading the data. This allows to send all of them and then wait to get them back later.
  req[[i_s]] <- wf_request(user = cds.user, request = request, transfer = F)
}

save( # grl, we are excluding grl because of its size on this repo. Feel free to keep it in your own project
  req,
  file = paste0("data/5_wind_graph/", gdl, "_request.Rdata")
)

# Check request at https://cds.climate.copernicus.eu/cdsapp#!/yourrequests
