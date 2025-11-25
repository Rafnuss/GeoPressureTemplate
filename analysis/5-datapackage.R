# https://raphaelnussbaumer.com/GeoPressureManual/geolocator-intro.html

library(GeoLocatoR)
library(zen4R)
library(frictionless)

# Set the Zenodo token: https://zenodo.org/account/settings/applications/tokens/new/
# keyring::key_set_with_value("ZENODO_PAT", password = "{your_zenodo_token}")

# Initialize Zenodo manager
zenodo <- ZenodoManager$new(token = keyring::key_get(service = "ZENODO_PAT"))


# Create a new Zenodo from GeoPressureTemplate
pkg <- create_gldp_geopressuretemplate()
z <- gldp_to_zenodo(pkg)
z <- zenodo$depositRecord(z, reserveDOI = TRUE, publish = FALSE)
browseURL(z$links$self_html)


# Retrieve a package from Zenodo (DOI)
z <- zenodo$getDepositionByConceptDOI("10.5281/zenodo.{ZENODO_ID - 1}")
pkg <- zenodo_to_gldp(z)


# Add data
pkg <- add_gldp_geopressuretemplate(pkg)

# Check package
print(pkg)
plot(pkg, "ring")
plot(pkg, "coverage")
plot(pkg, "map")
validate_gldp(pkg)

# Write datapackage
dir.create("data/datapackage", showWarnings = FALSE)
write_package(pkg, "data/datapackage/")

# Upload to Zenodo
for (f in list.files("data/datapackage/")) {
  zenodo$uploadFile(file.path("data/datapackage/", f), z)
}
