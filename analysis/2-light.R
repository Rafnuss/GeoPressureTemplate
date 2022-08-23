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
library(lubridate)
library(GeoLocTools)
setupGeolocation()

debug <- T

# Define the geolocator data logger id to use
gdl <- "18LX"

# Load the pressure file, also contains gpr, pam, col
load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))

# Define calibration period ----
while (!is.POSIXct(gpr$calib_1_start) | is.na(gpr$calib_1_start)) {
  message("First and last stationary period:")
  print(pam$sta[c(1, nrow(pam$sta)), ])
  invisible(readline(prompt = paste0(
    "Add the calib_1_start and calib_1_end in ata/gpr_settings.xlsx",
    ". Once it's done, press [enter] to proceed: "
  )))
  gpr <- read_excel("data/gpr_settings.xlsx") %>%
    filter(gpr$gdl_id == gdl_id)
}

# Compute twilight
twl <- find_twilights(pam$light, shift_k = gpr$shift_k)

if (debug) {
  # convert to geolight format for ploting
  raw_geolight <- pam$light %>%
    transmute(
      Date = date,
      Light = obs
    )

  # Check shift_k value
  lightImage(
    tagdata = raw_geolight,
    offset = gpr$shift_k / 60 / 60
  )
  tsimageDeploymentLines(raw_geolight$Date,
    lon = gpr$calib_lon, lat = gpr$calib_lat,
    offset = gpr$shift_k / 60 / 60, lwd = 3, col = adjustcolor("orange", alpha.f = 0.5)
  )

  abline(v = gpr$calib_2_start, lty = 1, col = "firebrick", lwd = 1.5)
  abline(v = gpr$calib_1_start, lty = 1, col = "firebrick", lwd = 1.5)
  abline(v = gpr$calib_2_end, lty = 2, col = "firebrick", lwd = 1.5)
  abline(v = gpr$calib_1_end, lty = 2, col = "firebrick", lwd = 1.5)
}


# Add calibration period
if (!file.exists(paste0("data/2_light/labels/", gpr$gdl_id, "_light-labeled.csv"))) {
  # Write the label file
  val <- (as.numeric(format(twl$twilight, "%H")) * 60 + as.numeric(format(twl$twilight, "%M"))
    + gpr$shift_k / 60 + 60 * 12) %% (60 * 24)
  plot(twl$twilight[twl$rise], val[twl$rise])

  write.csv(
    data.frame(
      series = ifelse(twl$rise, "Rise", "Set"),
      timestamp = strftime(twl$twilight, "%Y-%m-%dT00:00:00Z", tz = "UTC"),
      value = (as.numeric(format(twl$twilight, "%H")) * 60 + as.numeric(format(twl$twilight, "%M"))
        + gpr$shift_k / 60 + 60 * 12) %% (60 * 24),
      label = ifelse(is.null(twl$delete), "", ifelse(twl$delete, "Delete", ""))
    ),
    paste0("data/2_light/labels/", gpr$gdl_id, "_light.csv"),
    row.names = FALSE
  )
  browseURL("https://trainset.geocene.com/")
  invisible(readline(prompt = paste0(
    "Edit the label file data/2_light_labels/", gpr$gdl_id,
    "_light.csv. \n Once you've exported ", gpr$gdl_id,
    "_light-labeled.csv, press [enter] to proceed"
  )))
}

# Read the labeled file and update twilight
csv <- read.csv(paste0("data/2_light/labels/", gpr$gdl_id, "_light-labeled.csv"))
twl$deleted <- !csv$label == ""


if (debug) {
  lightImage(
    tagdata = raw_geolight,
    offset = gpr$shift_k / 60 / 60
  )
  tsimagePoints(twl$twilight,
    offset = gpr$shift_k / 60 / 60, pch = 16, cex = 1.2,
    col = ifelse(twl$deleted, "grey20", ifelse(twl$rise, "firebrick", "cornflowerblue"))
  )
}

# Subset calibration period
twl_calib <- twl %>%
  filter(!deleted) %>%
  filter(
    (twilight >= gpr$calib_1_start & twilight <= gpr$calib_1_end) |
      (twilight >= gpr$calib_2_start & twilight <= gpr$calib_2_end)
  )


# Add twilight information on
tmp <- which(mapply(function(start, end) {
  start < twl$twilight & twl$twilight < end
}, pam$sta$start, pam$sta$end), arr.ind = TRUE)
twl$sta_id <- 0
twl$sta_id[tmp[, 1]] <- tmp[, 2]


# Fit distribution of zenith angle ----
sun <- solar(twl_calib$twilight)
z <- refracted(zenith(sun, gpr$calib_lon, gpr$calib_lat))
fit_z <- density(z, adjust = gpr$kernel_adjust, from = 60, to = 120)



if (debug) {
  hist(z, freq = F)
  lines(fit_z, col = "red")

  # Compare with pressure
  load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))
  dur <- unlist(lapply(pressure_prob, function(x) difftime(metadata(x)$temporal_extent[2], metadata(x)$temporal_extent[1], units = "days")))
  long_id <- which(dur > 5)

  par(mfrow = c(2, 3))
  for (i_s in long_id) {
    twl_fl <- twl %>%
      filter(!deleted) %>%
      filter(twilight > pressure_timeserie[[i_s]]$date[1] & twilight < tail(pressure_timeserie[[i_s]]$date, 1))
    sun <- solar(twl_fl$twilight)
    z_i <- refracted(zenith(sun, pressure_timeserie[[i_s]]$lon[1], pressure_timeserie[[i_s]]$lat[1]))
    hist(z_i, freq = F, main = paste0("sta_id=", i_s, " n=", nrow(twl_fl)))
    lines(fit_z, col = "red")
  }

  # Light comparison
  lightImage(
    tagdata = raw_geolight,
    offset = gpr$shift_k / 60 / 60
  )
  tsimagePoints(twl$twilight,
    offset = gpr$shift_k / 60 / 60, pch = 16, cex = 1.2,
    col = ifelse(twl$deleted, "grey20", ifelse(twl$rise, "firebrick", "cornflowerblue"))
  )
  for (i_s in long_id) {
    twl_fl <- twl %>%
      filter(twilight > pressure_timeserie[[i_s]]$date[1] & twilight < tail(pressure_timeserie[[i_s]]$date, 1))
    tsimageDeploymentLines(twl_fl$twilight,
      lon = pressure_timeserie[[i_s]]$lon[1], pressure_timeserie[[i_s]]$lat[1],
      offset = gpr$shift_k / 60 / 60, lwd = 3, col = adjustcolor("orange", alpha.f = 0.5)
    )
  }
}

# Get grid information to create proability map identical to pressure
g <- as.data.frame(pressure_prob[[1]], xy = TRUE)
g$layer <- NA


# Compute the elevation angle of all twilight ----
twl_clean <- subset(twl, !deleted)
sun <- solar(twl_clean$twilight)
pgz <- apply(g, 1, function(x) {
  z <- refracted(zenith(sun, x[1], x[2]))
  approx(fit_z$x, fit_z$y, z, yleft = 0, yright = 0)$y
})

# Define the log-linear pooling value
w <- gpr$prob_light_w

# Create the probability map
light_prob <- c()
for (i_s in seq_len(nrow(pam$sta))) {
  id <- twl_clean$sta_id == pam$sta$sta_id[i_s]
  if (sum(id) > 1) {
    g$layer <- exp(colSums(w * log(pgz[id, ]))) # Log-linear equation express in log
  } else if (sum(id) == 1) {
    g$layer <- pgz[id, ]
  } else {
    g$layer <- 1
  }
  gr <- rasterFromXYZ(g)
  crs(gr) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
  metadata(gr) <- list(
    sta_id = pam$sta$sta_id[i_s],
    nb_sample = sum(id)
  )
  light_prob[[i_s]] <- gr
}

if (debug) {
  # Compute the most likely path
  path <- geopressure_map2path(light_prob)
  path$duration <- as.numeric(difftime(pam$sta$end, pam$sta$start, units = "days"))
  path <- subset(path, duration > 2)

  leaflet() %>%
    addProviderTiles(providers$Stamen.TerrainBackground) %>%
    addFullscreenControl() %>%
    addPolylines(lng = path$lon, lat = path$lat, opacity = 0.7, weight = 1, color = "#808080") %>%
    addCircles(lng = path$lon, lat = path$lat, opacity = 1, weight = path$duration^(0.3) * 10)


  # plot probability map
  li_s <- list()
  l <- leaflet() %>%
    addProviderTiles(providers$Stamen.TerrainBackground) %>%
    addFullscreenControl()
  for (i_r in seq_len(length(light_prob))) {
    i_s <- metadata(light_prob[[i_r]])$sta_id
    info <- pam$sta[pam$sta$sta_id == i_s, ]
    info_str <- paste0(i_s, " | ", info$start, "->", info$end)
    li_s <- append(li_s, info_str)
    l <- l %>% addRasterImage(light_prob[[i_r]], opacity = 0.8, colors = "OrRd", group = info_str)
  }
  l %>%
    addCircles(lng = gpr$calib_lon, lat = gpr$calib_lat, color = "black", opacity = 1) %>%
    addLayersControl(
      overlayGroups = li_s,
      options = layersControlOptions(collapsed = FALSE)
    ) %>%
    hideGroup(tail(li_s, length(li_s) - 1))
}

# Save ----
save(twl,
  light_prob,
  z,
  fit_z,
  file = paste0("data/2_light/", gpr$gdl_id, "_light_prob.Rdata")
)
