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


national_hcf_state_names <- unique(national_hcf$state_name)

# National Health Care Facilities
national_hcf_category <- unique(national_hcf$category)

national_hcf_filtered_ri <- national_hcf |> 
  filter(state_name == "Ogun",
         ri_service_status == TRUE,
         functional_status == "Functional") |> 
  select(state_name, ri_service_status, category, latitude, longitude, name) |> 
  rowid_to_column(var = "hcf_id")

national_hcf_filtered_pharmacies <- national_hcf |> 
  filter(state_name == "Ogun", category == "Pharmacy") |> 
  select(state_name, ri_service_status, category, latitude, longitude, name) |> 
  rowid_to_column(var = "hcf_id")


















