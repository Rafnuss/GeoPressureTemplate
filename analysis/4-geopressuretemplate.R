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
  geopressuretemplate(id)
}

