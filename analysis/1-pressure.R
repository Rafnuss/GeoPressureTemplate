library(GeoPressureR)
library(leaflet)
library(leaflet.providers)
library(leaflet.extras)
library(ggplot2)
library(plotly)
library(RColorBrewer)
library(dplyr)
library(raster)
library(readxl)

# Define the geolocator data logger id to use
gdl <- "18LX"

# Read its information from gpr_settings.xlsx
set <- read_excel("data/gdl_settings.xlsx") %>%
  filter(gdl_id == gdl)

# assert gdl in setting

# Read, classify and label ----
pam <- pam_read(paste0("data/0_PAM/", set$gdl_id),
  crop_start = set$crop_start,
  crop_end = set$crop_end
)

# Auto classication + writing, only done the first time
if (!file.exists(paste0("data/1_act_pres_labels/", set$gdl_id, "_act_pres-labeled.csv"))) {
  pam <- pam_classify(pam)
  trainset_write(pam, "data/1_act_pres_labels/")
  browseURL("https://trainset.geocene.com/")
  invisible(readline(prompt = paste0(
    "Edit the label file data/1_act_pres_labels/", set$gdl_id,
    "_act_pres.csv.\n Once you've exported ", set$gdl_id,
    "_act_pres-labeled.csv, press [enter] to proceed"
  )))
}

# Read the label and compute the stationary info
pam <- trainset_read(pam, "data/1_act_pres_labels/")
pam <- pam_sta(pam)

# define the discrete colorscale. Used at multiple places.
col <- rep(RColorBrewer::brewer.pal(9, "Set1"), times = ceiling((nrow(pam$sta) + 1) / 9))
col <- col[1:(nrow(pam$sta) + 1)]
names(col) <- levels(factor(c(0, pam$sta$sta_id)))


# Test 1 ----
pam$sta %>%
  mutate(
    duration = difftime(end, start, units = "hours"),
    next_flight_duration = difftime(lead(start), end, units = "hours")
  ) %>%
  filter(duration < 3) %>%
  arrange(duration)


# Test 2 ----
pressure_na <- pam$pressure %>%
  mutate(obs = ifelse(isoutliar | sta_id == 0, NA, obs))

p <- ggplot() +
  geom_line(data = pam$pressure, aes(x = date, y = obs), col = "grey") +
  geom_line(data = pressure_na, aes(x = date, y = obs, color = factor(sta_id))) +
  # geom_point(data = subset(pam$pressure, isoutliar), aes(x = date, y = obs), colour = "black") +
  theme_bw() +
  scale_color_manual(values = col) +
  scale_y_continuous(name = "Pressure(hPa)")

ggplotly(p, dynamicTicks = T) %>% layout(showlegend = F)



# Filter stationary period based on the number of pressure datapoint available
thr_dur <- set$thr_dur # 24*4 # duration in hour. Decrease this value down to set$thr_dur
res <- as.numeric(difftime(pam$pressure$date[2], pam$pressure$date[1], units = "hours"))
sta_id_keep <- pam$pressure %>%
  filter(!isoutliar & sta_id > 0) %>%
  count(sta_id) %>%
  filter(n * res > thr_dur) %>%
  .$sta_id

# Duplicate the pam data to avoid issue after filtering, and put NA on the sta to not consider
pam_short <- pam
pam_short$pressure <- pam_short$pressure %>%
  mutate(sta_id = ifelse(sta_id %in% sta_id_keep, sta_id, NA))

# Query pressure map
# We overwrite the setting parameter for resolution to make query faster at first
pressure_maps <- geopressure_map(pam_short$pressure,
  extent = c(set$extent_N, set$extent_W, set$extent_S, set$extent_E),
  scale = set$map_scale,
  max_sample = set$map_max_sample,
  margin = set$map_margin
)
# Convert to probability map
pressure_prob <- geopressure_prob_map(pressure_maps,
  s = set$prob_map_s,
  thr = set$prob_map_thr
)

# Compute the path of the most likely position
path <- geopressure_map2path(pressure_prob)

# Fix for altitude
# path$lat[path$sta_id==55] <- path$lat[path$sta_id==55] + 1

# Query timeserie of pressure based on these path
pressure_timeserie <- geopressure_ts_path(path, pam_short$pressure)

# Test 3 ----
p <- ggplot() +
  geom_line(data = pam$pressure, aes(x = date, y = obs), colour = "grey") +
  # geom_point(data = subset(pam$pressure, isoutliar), aes(x = date, y = obs), colour = "black") +
  geom_line(data = pressure_na, aes(x = date, y = obs, color = factor(sta_id)), size = 0.5) +
  geom_line(data = do.call("rbind", pressure_timeserie), aes(x = date, y = pressure0, col = factor(sta_id)), linetype = 2) +
  theme_bw() +
  scale_colour_manual(values = col) +
  scale_y_continuous(name = "Pressure(hPa)")

ggplotly(p, dynamicTicks = T) %>% layout(showlegend = F)


# Test 4 ----
par(mfrow = c(5, 6), mar = c(1, 1, 3, 1))
for (i_r in seq_len(length(pressure_timeserie))) {
  if (!is.null(pressure_timeserie[[i_r]])) {
    i_s <- unique(pressure_timeserie[[i_r]]$sta_id)
    df3 <- merge(pressure_timeserie[[i_r]], subset(pam$pressure, !isoutliar & sta_id == i_s), by = "date")
    df3$error <- df3$pressure0 - df3$obs
    hist(df3$error, main = i_s, xlab = "", ylab = "")
    abline(v = 0, col = "red")
  }
}

# Map the most likely position
sta_duration <- unlist(lapply(pressure_prob, function(x) {
  as.numeric(difftime(metadata(x)$temporal_extent[2], metadata(x)$temporal_extent[1], units = "days"))
}))
pal <- colorFactor(col, as.factor(seq_len(length(col))))
leaflet() %>%
  addProviderTiles(providers$Stamen.TerrainBackground) %>%
  addFullscreenControl() %>%
  addPolylines(lng = path$lon, lat = path$lat, opacity = 0.7, weight = 1, color = "#808080") %>%
  addCircles(lng = path$lon, lat = path$lat, opacity = 1, color = pal(factor(path$sta_id, levels = pam$sta$sta_id)), weight = sta_duration^(0.3) * 10)


# Export ----
save(pressure_timeserie,
  pressure_prob,
  pam,
  col,
  set,
  file = paste0("data/3_pressure_prob/", set$gdl_id, "_pressure_prob.Rdata")
)
