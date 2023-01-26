# libraries ----
library(vroom)        # Read a delimited file into a tibble
library(tidygeocoder) # Used for geocoding


library(osmdata)    # Open Street Map Overpass API
library(osrm)       # Open Street Map Routing API

library(sf)         # Simple Features
library(nngeo)      # Nearest Neighbors
library(mapview)    # Interactive Maps

library(tidyquant)  # Finance... Because why not?
library(tidyverse)  # Core tidy libs

national_hcf  <- st_read("data/national-health-care-facilities/health-care-facilities-primary-secondary-and-tertiary.geojson") #|> 

nga_education <- st_read("data/nga_education/NGA_Education.shp")

national_hcf_state_names <- unique(national_hcf$state_name)

# National Health Care Facilities
national_hcf_category <- unique(national_hcf$category)

saveRDS(list(state_values = national_hcf_state_names, category_values = national_hcf_category), file = "select_item_data.rds")

national_hcf_filtered <- national_hcf |> 
  filter(state_name == "Fct", category == "Primary Health Clinic", 
         functional_status == "Functional") |> 
  select(latitude, longitude,name) |> 
  rowid_to_column(var = "hcf_id")

inc_loc <- "1 Dunokofia street Area11 Garki Abuja" #"Ojota Chemical Market, Ojota, Lagos"

# * Geocoding: Address -> Lat Long ----


inc_locations_latlon_tbl <- geo(inc_loc, method = "arcgis") 

# convert to geometry
inc_locations_latlon_tbl_sf <- inc_locations_latlon_tbl |> 
  st_as_sf(
    coords = c("long", "lat"),
    crs    = 4326
  ) |> 
 left_join(inc_locations_latlon_tbl) |> 
  rowid_to_column(var = "inc_id")


# 3.0 NEAREST NEIGHBORS ----
# * Alternatively we can use sfnetworks
# * I'm going to use nngeo

# * Getting Nearest Neighbors with nngeo ----


if(nrow(national_hcf_filtered)<=3){
  network_ids <- st_nn(
    x = inc_locations_latlon_tbl_sf, #berlin_distributors_sf,
    y = national_hcf_filtered, #berlin_customers_sf,
    k = nrow(national_hcf_filtered),
    progress = T
  )
} else{
  network_ids <- st_nn(
    x = inc_locations_latlon_tbl_sf, #berlin_distributors_sf,
    y = national_hcf_filtered, #berlin_customers_sf,
    k = 3,
    #k = nrow(national_hcf_filtered),
    progress = T
  )
}
# network_ids <- st_nn(
#   x = inc_locations_latlon_tbl_sf, #berlin_distributors_sf,
#   y = national_hcf_filtered, #berlin_customers_sf,
#   k = 3,
#   #k = nrow(national_hcf_filtered),
#   progress = T
# )



network_lines_sf <- st_connect(
  x = inc_locations_latlon_tbl_sf, #berlin_distributors_sf,
  y = national_hcf_filtered, #berlin_customers_sf,
  ids = network_ids
)



# mapview(
#   berlin_medium_streets_sf$osm_lines, 
#   color      = "green",
#   layer.name = "Streets",
#   map.types  = "CartoDB.DarkMatter",
#   lwd        = 0.5 
# ) +
#   mapview(
#     berlin_highways_sf$osm_lines,
#     layer.name = "Highways",
#     color      = "purple",
#     lwd        = 2
#   ) +
  m <- mapview(
    national_hcf_filtered[unlist(network_ids),], #berlin_customers_sf,
    col.region = "cyan",
    color      = "white",
    layer.name = "National Hospitals",
    cex        = 12
  ) +
  mapview(
    inc_locations_latlon_tbl_sf, #berlin_distributors_sf,
    col.region = "magenta",
    color      = "white",
    layer.name = "Incident location",
    cex        = 20
  ) +
  mapview(
    network_lines_sf,
    color      = "yellow"
  )

  m

  













