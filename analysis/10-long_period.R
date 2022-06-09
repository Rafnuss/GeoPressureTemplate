
library(GeoPressureR)
library(raster)
library(dplyr)
library(ggplot2)

# gdl_id <- "22BT"

load(paste0("data/1_pressure/", gdl, "_pressure_prob.Rdata"))

# define threshold of duration
thr_sta_dur <- 5

# However some location are probably the same, but just separated by a few hour flight
# sta_keep = c()
# for (i_s in ){
#   mt <- metadata(static_prob[[i_s]])
#   fl <- mt$flight
#   fl_dur <- sum(lapply(fl, function(x){
#     difftime(x$end, x$start, units = "hours")
#   }))
#   difftime(temporal_extent[2], pam$sta$start, units = "days")
# }

sta_thr <- pam$sta$sta_id[difftime(pam$sta$end, pam$sta$start, units = "days") > thr_sta_dur]
# remove the equipement site
# sta_thr <- tail(sta_thr,-1)

pressure_prob_lg <- c()

for (i_sta in sta_thr) {
  i_s <- which(unlist(lapply(pressure_prob, function(x) {
    metadata(x)$sta_id
  })) == i_sta)

  # Find the extent of the map for the 90% percentile
  thr_prob_percentile <- .90
  probt <- as.data.frame(pressure_prob[[i_s]], xy = T)
  probt$layer[is.na(probt$layer)] <- 0
  probt$layer <- probt$layer / sum(probt$layer, na.rm = T)
  ls <- sort(probt$layer)
  id_prob_percentile <- sum(cumsum(ls) <= (1 - thr_prob_percentile))
  thr_prob <- ls[id_prob_percentile + 1]
  probtc <- subset(probt, layer >= thr_prob)
  extent_sm <- c(min(probtc$x), max(probtc$x), min(probtc$y), max(probtc$y))

  # request the pressure at the max resolution and take higher samples
  pressure_maps_sm <- geopressure_map(subset(pam$pressure, sta_id == i_sta),
                                      extent = c(extent_sm[4], extent_sm[1], extent_sm[3], extent_sm[2]),
                                      scale = 10,
                                      max_sample = 100,
                                      margin = 20
  )

  # Convert to probability map
  pressure_prob_sm <- geopressure_prob_map(pressure_maps_sm,
                                           s = gpr$prob_map_s,
                                           thr = gpr$prob_map_thr
  )
  # Take only the first value
  pressure_prob_sm <- pressure_prob_sm[[1]]

  # set prob=0 to NA
  tmp <- values(pressure_prob_sm)
  tmp[is.na(tmp)] <- 0
  tmp <- tmp / sum(tmp)
  tmps <- sort(tmp)
  id_prob_percentile <- sum(cumsum(tmps) <= (1 - thr_prob_percentile))
  thr_prob <- tmps[id_prob_percentile + 1]
  tmp[tmp < thr_prob] <- NA
  values(pressure_prob_sm) <- tmp

  pressure_prob_lg <- c(pressure_prob_lg, pressure_prob_sm)
}

save(pressure_prob_lg,
     file = paste0("data/10_long_period/", gdl, ".Rdata")
)
