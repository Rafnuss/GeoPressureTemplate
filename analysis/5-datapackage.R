library(GeoLocatoR)
library(zen4R)
library(frictionless)

## Publish Data Package
# Introduction: hhttps://raphaelnussbaumer.com/GeoPressureManual/geolocator-intro.html
# Detailed instruction: https://raphaelnussbaumer.com/GeoPressureManual/geolocator-create.html

# Create the datapackage
pkg <- create_gldp_geopressuretemplate(".")

#################
# Create Metadata
pkg$title <- "GeoLocator Data Package: {Species} in {country}"

# Contributors/creators:
# Default is to take the GeoPressureTemplate authors, but it is common that
# additional co-authors should be added for the datapackage
pkg$contributors <- list( # required
  list(
    title = "Raphaël Nussbaumer",
    roles = c("ContactPerson", "DataCurator", "ProjectLeader"),
    email = "raphael.nussbaumer@vogelwarte.ch",
    path = "https://orcid.org/0000-0002-8185-1020",
    organization = "Swiss Ornithological Institute"
  )
)

# There are no embargo by default (1970-01-01)
pkg$embargo <- "2030-01-01"

# Licences
# Code licenses are often not the same as data licences.
pkg$licenses = list(list(
  name = "CC-BY-4.0",
  title = "Creative Commons Attribution 4.0",
  path = "https://creativecommons.org/licenses/by/4.0/"
))

# Review the description, often, you will want to be more talkative here.
# pkg$description

# Add keywords
pkg$keywords <- c("Woodland Kingfisher", "intra-african", "multi-sensor geolocator")

# Funding sources
pkg$grants <- c("Swiss Ornithological Intitute")

# Related Identifiers
# e.g. papers, project pages, derived datasets, etc.
pkg$relatedIdentifiers <- list(
  list(
    relationType = "IsPartOf",
    relatedIdentifier = "10.5281/zenodo.11207081",
    relatedIdentifierType = "DOI"
  )
)

# print(pkg)




#################
# Add data
pkg <- pkg %>% add_gldp_geopressuretemplate()


# Check package
plot(pkg)
validate_gldp(pkg)


#################
# Write datapackage

## Option 1: Manual
# https://zenodo.org/uploads/new
pkg$id <- "https://doi.org/10.5281/zenodo.{ZENODO_ID - 1}"
# e.g. "10.5281/zenodo.14620590" for a DOI reserved as 10.5281/zenodo.14620591
# Update the bibliographic citation with this new DOI
pkg <- pkg %>% update_gldp_bibliographic_citation()

dir.create("data/datapackage", showWarnings = FALSE)
write_package(pkg, "data/datapackage/")

# Use the information in datapackage.json to fill the zenodo form.

## Option 2: API
# Create token and Zenodo manager
# https://zenodo.org/account/settings/applications/tokens/new/
keyring::key_set_with_value("ZENODO_PAT", password = "{your_zenodo_token}")
zenodo <- ZenodoManager$new(token = keyring::key_get(service = "ZENODO_PAT"))

# Create a zenodo from data package
z <- gldp2zenodoRecord(pkg)

z <- zenodo$depositRecord(z, reserveDOI = TRUE, publish = FALSE)

pkg$id <- paste0("https://doi.org/", z$getConceptDOI())
pkg <- pkg %>%
  update_gldp()

for (f in list.files("data/datapackage/")) {
  zenodo$uploadFile(file.path("data/datapackage/", f), z)
}


#################
# Update metadata from Zenodo
# If you modify the metadata on zenodo, you can update your pkg with those information with

z_updated <- zenodo$getDepositionByConceptDOI(z$getConceptDOI())
pkg <- zenodoRecord2gldp(z_updated, pkg)


## Make sure to submit to Zenodo community: https://zenodo.org/communities/geolocator-dp/
