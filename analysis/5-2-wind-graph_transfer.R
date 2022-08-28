library(ecmwfr)

# Define which track to work with
gdl <- "18LX"

load(paste0("data/5_wind_graph/", gdl, "_request.Rdata"))

cds.key <- Sys.getenv("cds.key")
cds.user <- Sys.getenv("cds.user")
wf_set_key(user = cds.user, key = cds.key, service = "cds")

# Check that the requests have finished at https://cds.climate.copernicus.eu/cdsapp#!/yourrequests

# define and create directory to store the data
dir.save <- paste0("data/5_wind_graph/", gdl)
dir.create(dir.save, showWarnings = F)

# Download a file for each stationary period
for (i_s in seq(1, length(req))) {
  filename <- paste0(gdl, "_", i_s, ".nc")
  # wf_transfer seems to fail for some reason with the following error
  # error in curl::curl_fetch_disk(url, x$path, handle = handle) :
  # HTTP/2 stream 0 was not closed cleanly: INTERNAL_ERROR (err 2))
  # We try each request 3 times before continuing.
  attempt <- 1
  r <- NULL
  while (is.null(r) && attempt <= 3) {
    attempt <- attempt + 1
    try(
      r <- wf_transfer(url =  basename(req[[i_s]]$get_url()), service = "cds", user = cds.user, path = dir.save, filename = filename)
    )
  }
  if (is.null(r)) {
    paste0("data for stationary period ", i_s, " was not downloaded.")
  }
}
