# See https://raphaelnussbaumer.com/GeoPressureManual/geopressuretemplate-workflow.html

library(GeoPressureR)

# Run workflow step-by-step for a single tag
id <- "18LX" # Run a single tag
geopressuretemplate_config(id)
tag <- geopressuretemplate_tag(id)
graph <- geopressuretemplate_graph(id)
geopressuretemplate_pressurepath(id)


## Run workflow for all tags
list_id <- tail(names(yaml::yaml.load_file("config.yml", eval.expr = FALSE)), -1)

for (id in list_id){
  cli::cli_h1("Run tag for {id}")
  geopressuretemplate_tag(id)
}

# Manual checking of coherence
id = "16LF"
geopressureviz(id)

# Add wind
for (id in list_id){
  cli::cli_h1("Run tag_download_wind for {id}")
  load(glue::glue("./data/interim/{id}.RData"))
  a<-tag_download_wind(tag)
}

# Run graph
for (id in list_id){
  cli::cli_h1("Run graph for {id}")
  geopressuretemplate_graph(id)
}

# Run pressurepath
for (id in list_id){
  cli::cli_h1("Run pressurepath for {id}")
  geopressuretemplate_pressurepath(id)
}
