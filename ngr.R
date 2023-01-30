# LIBRARIES ----

library(osmdata)    # Open Street Map Overpass API
library(osrm)       # Open Street Map Routing API

library(sf)         # Simple Features
library(nngeo)      # Nearest Neighbors
library(mapview)    # Interactive Maps

library(tidyverse)  # Core tidy libs
library(tidyquant)  # Finance... Because why not?

library(googletraffic)


# 1.0 OSM OVERPASS API ----
# - Get roads, water, etc
# - Resource: # https://wiki.openstreetmap.org/wiki/Map_features

abj_bbox <- getbb("Abuja, Nigeria")


# * Getting Major Highways ----

abj_highways_sf <- opq(abj_bbox) %>%
  add_osm_feature(
    key   = "highway", 
    value = c("motorway", "primary", "motorway_link", "primary_link")
  ) %>%
  osmdata_sf() 


abj_highways_sf %>% write_rds("data/data_bsu/abj_highways_sf.rds")

abj_highways_sf <- read_rds("data/data_bsu/abj_highways_sf.rds")

mapview(abj_highways_sf$osm_lines)


# * Getting Smaller roads  -----

abj_medium_streets_sf <- opq(abj_bbox) %>%
  add_osm_feature(
    key   = "highway", 
    value = c("secondary", "tertiary", "secondary_link", "tertiary_link")
  ) %>%
  osmdata_sf()

abj_medium_streets_sf %>% write_rds("data/data_bsu/abj_medium_streets_sf.rds")

abj_medium_streets_sf <- read_rds("data/data_bsu/abj_medium_streets_sf.rds")

# * Visualization ----

mapview(
  abj_medium_streets_sf$osm_lines, 
  color = "yellow",
  layer.name = "Streets"
) +
  mapview(
    abj_highways_sf$osm_lines,
    layer.name = "Highways",
    color = "purple"
  )



# Lagos

lag_bbox <- getbb("Lagos, Nigeria")


# * Getting Major Highways ----

lag_highways_sf <- opq(lag_bbox) %>%
  add_osm_feature(
    key   = "highway", 
    value = c("motorway", "primary", "motorway_link", "primary_link")
  ) %>%
  osmdata_sf() 


lag_highways_sf %>% write_rds("data/data_bsu/lag_highways_sf.rds")

lag_highways_sf <- read_rds("data/data_bsu/lag_highways_sf.rds")

mapview(lag_highways_sf$osm_lines)


# * Getting Smaller roads  -----

lag_medium_streets_sf <- opq(lag_bbox) %>%
  add_osm_feature(
    key   = "highway", 
    value = c("secondary", "tertiary", "secondary_link", "tertiary_link")
  ) %>%
  osmdata_sf()

lag_medium_streets_sf %>% write_rds("data/data_bsu/lag_medium_streets_sf.rds")

lag_medium_streets_sf <- read_rds("data/data_bsu/lag_medium_streets_sf.rds")

# * Visualization ----

mapview(
  lag_medium_streets_sf$osm_lines, 
  color = "yellow",
  layer.name = "Streets"
) +
  mapview(
    lag_highways_sf$osm_lines,
    layer.name = "Highways",
    color = "purple"
  )















