library(ecmwfr)

# Define which track to work with
gdl <- "18LX"

load(paste0("data/5_wind_graph/", gdl, "_request.Rdata"))

cds.key <- Sys.getenv('cds.key')
cds.user <- Sys.getenv('cds.user')
wf_set_key(user = cds.user, key = cds.key, service = "cds")

# Check that the requests have finished at https://cds.climate.copernicus.eu/cdsapp#!/yourrequests

# define and create directory to store the data
dir.save <- paste0("data/5_wind_graph/", gdl)
dir.create(dir.save, showWarnings = F)

# Download a file for each stationary period
for (i_s in seq_len(length(req))){
  filename = paste0(gdl,"_",i_s,".nc")
  wf_transfer(url = req[[i_s]]$request_id, service = "cds", user = cds.user, path = dir.save, filename=filename)
}
