# DSN Webinar
# Introduction to Interactive Map for Business Data Visualization Using R, Part 1 ----

## Agenda
# 1. Basic understanding of geospatial elements
# 2. Access geospatial datasets from various sources
# 3. Import geospatial data into your R session
# 4. Transform and tidy (wrangle) geospatial data for mapping Visualize data to present insightful observations
# 5. Make a colorful and informative map



# libraries ----
# install.packages("vroom")
library(tidyverse)    # collection of R packages designed for data science
library(vroom)        # Read a delimited file into a tibble
library(tidygeocoder) # Used for geocoding
library(sf)           # Used for creating simple features objects
library(mapview)      # Used for creating interactive maps

# Vectors
# * Simple feature geometry types ----
#   - We have Point, Linestring, Polygon, Multipoint,  Mulitlinestring, Multipolygon, & Geomatrycollection

# Points could be the location of hospital in Agege in the Lagos, 
# or the location of Lassa fever cases, 
# or the location of major intersections within a locality.

# ** Point ---
?st_point
pt_A <- st_point(c(6.55, 3.40))

mapview(pt_A)

pt_A %>% mapview()

# ** Multipoint ----

pt_B <- st_point(c(12.50, 4.38))
pt_C <- st_point(c(15.50, 6.38))

# Combine the points as a single vector i.e. multiple points
pt_ABC <- c(pt_A, pt_B, pt_C)

pt_ABC %>% mapview()

# ** Linestring ----
# Lines could be the location of a street, 
#stream or train tracks, 
# the shortest distance 
# between someone’s house and the nearest healthcare center, 
# or a major road. 
?st_cast
ls_ABC <- pt_ABC %>% st_cast("LINESTRING")

ls_ABC %>% mapview()

# Add the points to the linestring
mapview(ls_ABC) + mapview(pt_ABC)


# ** Multilinestring ----

ls_XYZ <- st_linestring(
  rbind(c(1.50, 12.50), c(6.55, 3.40), c(12.50, 3.38))
)
ls_XYZ_inv <- st_linestring(
  rbind(c(1.50, 3.38), c(6.55, 8.40))
)

pts_rst <- st_linestring(rbind(c(6.582351, 3.348253), c(6.579167, 3.349491),
                               c(6.580659, 3.354000)))

pts_xyz <- st_linestring(rbind(c(6.580659, 3.354000),
                               c(6.577547, 3.355245),c(6.575526, 3.351771)))

pts_rst %>% mapview()

pts_xyz %>% mapview()

mline_rst_xyz <- c(pts_rst, pts_xyz)

mline_rst_xyz %>% mapview()

# ** Polygon ----

# Polygons could be lGA boundaries, school’s perimeter lines, 
# or dumping site.

mline_rst_xyz %>%
  st_cast("POLYGON") %>%
  mapview()



# Understanding Geocoding and Reverse Geocoding ----

# * Geocoding: Generate Latitude, Longitude from Address ->  ----
# getting geocodes for DSN office address
?geo

geo("33 Queen St, Alagomeji-Yaba, Lagos", method = "arcgis")
geo("University of Lagos, Akoka Yaba, LAGOS", method = "arcgis")

# * Reverse Geocoding: Convert Latitude, Longitude to Address ----
# using geocodes for
tibble(
  latitude = c(6.50, 6.52),
  longitude = c(3.38, 3.39)
) %>%
  reverse_geocode(
    lat = latitude,
    long = longitude,
    method = 'osm',
    full_results = TRUE
  ) %>% View()


# Introduction to Simple Features ----

# * Converting from Lat/Lon to Simple Features ----
# i.e. geometry
tibble(
  latitude = c(6.50, 6.52),
  longitude = c(3.38, 3.39)
) %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs    = 4326
  )

# * Visualizing in 1 line of code ----

tibble(
  latitude = c(6.50, 6.52),
  longitude = c(3.38, 3.39)
) %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs    = 4326
  ) %>% mapview()


# Visualizing data on geographical maps ----

# * Explore, Download and Import GRID3 data

# https://grid3.gov.ng/datasets
# reading geojson data from grid3 using sf functions 
abia  <- st_read("data/grid3/abia-health-care-facilities-primary-secondary-and-tertiary/health-care-facilities-primary-secondary-and-tertiary.geojson")
# all states
national  <- st_read("data/grid3/national-health-care-facilities-primary-secondary-and-tertiary/health-care-facilities-primary-secondary-and-tertiary.geojson")

# * Using ggplot2 -----
ggplot(abia) + geom_sf() + theme_minimal()

ggplot(national) + geom_sf() + theme_minimal()

# * Using Mapview ----

mapview(abia)

mapview(national)


# * Prepared R data file
# national data
health_care_facilities_nga <- read_rds("data/grid3/health_care_facilities_nga.rds")  

#mapview(health_care_facilities_nga)



# * * Aggregate all facilities by states

# * * Aggregating a simple features data

health_care_facilities_nga %>% 
  group_by(state_name) %>% 
  summarise(no_of_facilities = n()) %>% 
  ungroup() %>% 
  mapview(
    zcol       = "no_of_facilities",
    color      = "white",
    map.types  = "CartoDB.DarkMatter",
    layer.name = "No of Facilities"
  )

# converting sf to data frame before aggregating

# loading a new data set contaning state latitudes and longitudes
states_latlon <- read_rds("data/grid3/states_latlon.rds") %>%
  # fix name differences
  mutate(States = case_when(
    States == "Federal Capital Territory" ~ "Fct",
    States == "Nassarawa" ~ "Nasarawa",
    TRUE~States
  ))

hcf_tbl <- data.frame(health_care_facilities_nga) %>% 
  select(1:24) %>% 
  left_join(states_latlon, by = c("state_name" = "States"))%>%
  # add the geometry for the states
  st_as_sf(
    coords = c("Longitude", "Latitude"),
    crs    = 4326
  )

# group data by state name
hcf_by_state <- hcf_tbl %>% 
  group_by(state_name) %>% 
  # summarize total number of facilities by states
  summarise(no_of_facilities = n()) %>% 
  ungroup()

# view on the map
hcf_by_state %>% 
  mapview(
    zcol       = "no_of_facilities",
    color      = "white",
    map.types  = "CartoDB.DarkMatter",
    layer.name = "No of Facilities"
  )


# References

# https://cran.r-project.org/web/packages/mapview/mapview.pdf
# https://rdrr.io/cran/mapview/man/mapView.html
# https://cran.r-project.org/package=sf
# https://jessecambon.github.io/tidygeocoder/
# https://cran.r-project.org/web/packages/tidygeocoder/vignettes/tidygeocoder.html

## Thank you










