library(ecmwfr)

# Define which track to work with
gdl <- "18LX"

# Load
load(paste0("data/3_static/", gdl, "_static_prob.Rdata"))

# Set credential
Sys.setenv( cds_key="Insert_your_CDS_API_KEY_here")
Sys.setenv( cds_user="Insert_your_CDS_UID_here")

# You can see them with
# usethis::edit_r_environ()
# cds_key <- Sys.getenv("cds_key")
# cds_user <- Sys.getenv("cds_user")

graph_download_wind(pam,
                    area = static_prob,
                    # cds_key="Insert_your_CDS_API_KEY_here"
                    # cds_user="Insert_your_CDS_UID_here"
                    )

# Check request at https://cds.climate.copernicus.eu/cdsapp#!/yourrequests
