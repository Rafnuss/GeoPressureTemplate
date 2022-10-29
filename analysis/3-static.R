library(GeoPressureR)
library(leaflet)
library(leaflet.providers)
library(leaflet.extras)
library(ggplot2)
library(plotly)
library(RColorBrewer)
library(raster)
library(dplyr)
library(readxl)

debug <- T

# Define the geolocator data logger id to use
gdl <- "18LX"

# Load the pressure file, also contains set, pam, col
load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
load(paste0("data/2_light/", gdl, "_light_prob.Rdata"))

# Define the threshold of the stationary period to consider
thr_sta_dur <- gpr$thr_dur # in hours

sta_pres <- unlist(lapply(pressure_prob, function(x) raster::metadata(x)$sta_id))
sta_light <- unlist(lapply(light_prob, function(x) raster::metadata(x)$sta_id))
sta_thres <- pam$sta$sta_id[difftime(pam$sta$end, pam$sta$start, units = "hours") > thr_sta_dur]

# Get the sta_id present on all three data sources
sta_id_keep <- intersect(intersect(sta_pres, sta_light), sta_thres)

# Filter pressure and light map
pressure_prob <- pressure_prob[sta_pres %in% sta_id_keep]
light_prob <- light_prob[sta_light %in% sta_id_keep]


# Flight
flight <- list()
for (i_f in seq_len(length(sta_id_keep) - 1)) {
  from_sta_id <- sta_id_keep[i_f]
  to_sta_id <- sta_id_keep[i_f + 1]
  flight[[i_f]] <- list(
    start = pam$sta$end[seq(from_sta_id, to_sta_id - 1)],
    end = pam$sta$start[seq(from_sta_id + 1, to_sta_id)],
    sta_id = seq(from_sta_id, to_sta_id - 1)
  )
}
flight[[i_f + 1]] <- list()


# static prob
static_prob <- mapply(function(light, pressure, flight) {
  # define static prob as the product of light and pressure prob
  static_prob <- light * pressure

  # define metadata
  metadata(static_prob) <- metadata(pressure)
  metadata(static_prob)$flight <- flight

  # return
  static_prob
}, light_prob, pressure_prob, flight)




# Overwrite prob at calibration
# Get lat lon
lat <- seq(raster::ymax(static_prob[[1]]), raster::ymin(static_prob[[1]]), length.out = nrow(static_prob[[1]]) + 1)
lat <- lat[seq_len(length(lat) - 1)] + diff(lat[1:2]) / 2
lon <- seq(raster::xmin(static_prob[[1]]), raster::xmax(static_prob[[1]]), length.out = ncol(static_prob[[1]]) + 1)
lon <- lon[seq_len(length(lon) - 1)] + diff(lon[1:2]) / 2

lon_calib_id <- which.min(abs(gpr$calib_lon - lon))
lat_calib_id <- which.min(abs(gpr$calib_lat - lat))

stopifnot(metadata(static_prob[[1]])$sta_id == 1)
tmp <- as.matrix(static_prob[[1]])
tmp[!is.na(tmp)] <- 0
tmp[lat_calib_id, lon_calib_id] <- 1
values(static_prob[[1]]) <- tmp

if (!is.na(gpr$calib_2_start) & abs(difftime(gpr$calib_2_end, gpr$crop_end, units = "days")) < 3) {
  if (!is.na(gpr$calib_2_lat)) {
    lon_calib_id <- which.min(abs(gpr$calib_2_lon - lon))
    lat_calib_id <- which.min(abs(gpr$calib_2_lat - lat))
  }
  tmp <- as.matrix(static_prob[[length(static_prob)]])
  tmp[!is.na(tmp)] <- 0
  tmp[lat_calib_id, lon_calib_id] <- 1
  values(static_prob[[length(static_prob)]]) <- tmp
}



# Get pressure timeserie at the best match of static
path <- geopressure_map2path(static_prob)
static_timeserie <- geopressure_ts_path(path, pam$pressure)

if (debug) {
  # GeopressureViz
  path_modified <- geopressureviz(
    pam = pam,
    static_prob = static_prob,
    pressure_prob = pressure_prob,
    light_prob = light_prob,
    pressure_timeserie = static_timeserie
  )

  # Pressure
  path_modified_timeserie <- geopressure_ts_path(path_modified, pam$pressure)

  path_modified_ts_bind <- do.call("rbind", path_modified_timeserie) %>%
    filter(!is.na(sta_id))

  # To make the labeling easier, you can replace pam$pressure$obs by the difference between
  # pam$pressure$obs and pressure_timeserie$pressure0 to see the anomalies.
  # Because trainset_read does not read the actual value of obs, but simply the label, it won't
  # impact your code
  pam_diff <- pam
  pam_diff$pressure <- pam_diff$pressure %>%
    left_join(path_modified_ts_bind %>% dplyr::select(c("date", "pressure0")), by = "date") %>%
    rename(obs_ref = pressure0)

  trainset_write(pam_diff, "data/1_pressure/labels/", filename = paste0(pam$id, "_act_pres"))

  # We can automatically extract some outlier based on s value
  # pam_diff_pressure <- pam_diff_pressure %>%
  #  mutate( isoutlier = ifelse(!isoutlier&abs(diff)>4*gpr$prob_map_s&sta_id>0, TRUE, isoutlier))
  # message(sum(pam_diff_pressure$isoutlier)-sum(pam$pressure$isoutlier), " new outlier automatically added")
  twl_path <- left_join(twl, path_modified) %>%
    mutate(
      twilight = twilight(twilight,
        lon = lon, lat = lat, rise = rise, zenith = 96
      )
    ) %>%
    filter(!is.na(twilight))

  write.csv(
    df <- rbind(
      data.frame(
        series = ifelse(twl$rise, "Rise", "Set"),
        timestamp = strftime(twl$twilight, "%Y-%m-%dT00:00:00Z", tz = "UTC"),
        value = (as.numeric(format(twl$twilight, "%H")) * 60 + as.numeric(format(twl$twilight, "%M"))
          + gpr$shift_k / 60 + 60 * 12) %% (60 * 24),
        label = ifelse(is.na(twl$delete), "", ifelse(twl$delete, "Delete", ""))
      ),
      data.frame(
        series = ifelse(twl_path$rise, "Set_ref", "Rise_ref"),
        timestamp = strftime(twl_path$twilight, "%Y-%m-%dT00:00:00Z", tz = "UTC"),
        value = (as.numeric(format(twl_path$twilight, "%H")) * 60 + as.numeric(format(twl_path$twilight, "%M"))
          + gpr$shift_k / 60 + 60 * 12) %% (60 * 24),
        label = ""
      )
    ),
    paste0("data/2_light/labels/", gpr$gdl_id, "_light.csv"),
    row.names = FALSE
  )
}

if (debug) {
  # Check 1
  static_prob_n <- lapply(static_prob, function(x) {
    probt <- raster::as.matrix(x)
    probt[is.na(probt)] <- 0
    probt / sum(probt, na.rm = T)
  })
  tmp <- unlist(lapply(static_prob_n, sum)) == 0
  if (any(tmp)) {
    warning(paste0(
      "The `static_prob` provided has a probability map equal to ",
      "zero for the stationay period: ", which(tmp)
    ))
  }


  ## Check 2
  for (i_s in seq_len(length(static_prob) - 1)) {
    cur <- as.matrix(static_prob[[i_s]]) > 0
    cur[is.na(cur)] <- F
    nex <- as.matrix(static_prob[[i_s + 1]]) > 0
    nex[is.na(nex)] <- F

    mtf <- metadata(static_prob[[i_s]])
    flight_duration <- as.numeric(sum(difftime(mtf$flight$end, mtf$flight$start, unit = "hours"))) # hours
    resolution <- mean(res(static_prob[[1]])) * 111 # assuming 1°= 111km
    thr_gs <- # Assuming a max groundspeed of 150km/h
      # Accepting a minimium of 3 grid resolution for noise/uncertainty.
      flight_duration <- pmax(flight_duration, resolution * 3 / gpr$thr_gs)

    # Check possible position at next stationary period
    possible_next <- (EBImage::distmap(!cur) * resolution / flight_duration) < gpr$thr_gs

    if (sum(possible_next & nex) == 0) {
      stop(paste("There are no possible transition from stationary period", i_s, "to", i_s + 1, ". Check part 1 process (light and pressure)", sep = " "))
    }
  }
}

## Save ----
save(
  static_prob,
  static_timeserie,
  file = paste0("data/3_static/", gpr$gdl_id, "_static_prob.Rdata")
)
