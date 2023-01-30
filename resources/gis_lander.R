library(leaflet)
library(sf)
library(tidyverse)
library(here)
library(janitor)
library(vroom)

docks <- vroom(here('data', 'JC-202212-citibike-tripdata.csv.zip')) |> 
  st_as_sf(
    # which columns to use as coordinates
    # always forget long/lat or Long/Lat
    coords=c('start_lng', 'start_lat'),
    # keep the coordinate columns
    remove=FALSE,
    # projection system
    crs=4326
  )
  
# using dplyr
docks |> select(id, stationName, latitude, longitude)

nyc <- st_read('data/nycdata.json')

nyc |> select(-Shape__Area,-Shape__Length, -NTA2020)

plot(docks)

docks |> select(geometry) |> plot()

nyc |> select(geometry) |> plot()
docks |> select(geometry) |> plot(col='blue',add=TRUE)

ggplot(docks) +
  geom_sf()+
  coord_sf()

ggplot(docks) +
  geom_sf(data = nyc)+
  geom_sf()+
  coord_sf()

# How many docks in each neighborhood?
# Spatial Join

docks_in_neighborhoods <- docks |> 
  # only care about the station name and geometry
  select(start_station_name, geometry) |> 
  st_join(
    # only need these columns from neighborhood tibble
    nyc |> select(BoroName, NTAName, geometry),
    # join rows where there is same over lap between
    # a dock and a neighborhood
    join=st_intersects,
    # keep only docks that are in a neighborhood
    # this will ignore Jersey City
    left=FALSE
  )

count_by_neighborhood <- docks_in_neighborhoods |> 
  # remove geometry for fast counting
  st_drop_geometry() |> 
  count(NTAName) |> 
  # join the counts into the nyc neighborhood object
  right_join(nyc, by=c("NTAName"="NTAName")) |> 
  st_as_sf()

count_by_neighborhood |> select(NTAName, n, BoroName, geometry)

ggplot(count_by_neighborhood, aes(fill=n))+
  geom_sf()+
  coord_sf()

#tmap

library(tmap)
tm_shape(docks)+
  tm_dots()


tm_shape(nyc)+
  tm_polygons()+
  tm_shape(docks)+
  tm_dots()

tm_shape(count_by_neighborhood)+
  tm_polygons(col = 'n')

# leaflet
leaflet(elementId='Docks') |> 
  addTiles() |> 
  addCircles(data = docks)

leaflet(elementId='DocksHoods') |> 
  addTiles() |> 
  addPolygons(data = nyc, color = 'black', 
              weight = 3, opacity = 0.2, 
              popup = ~NTAName) |> 
  addCircles(data = docks, 
             popup = ~start_station_name)

library(leafgl)
leaflet(elementId = 'DocksHoodsGL') |> 
  addTiles() |> 
  addGlPolygons(data = nyc |> st_cast('POLYGON'), 
                popup = 'NTAName', fillColor = 'black') |> 
  addGlPoints(data=docks, popup = 'stationName')


dock_palette <- colorQuantile(palette = "Dark2",
                              domain = count_by_neighborhood$n,
                              na.color = "transparent")
leaflet(elementId = "DocksHoodsCount") |> 
  addPolygons(data = count_by_neighborhood, opacity = 1,
              color = "black", fillColor = ~dock_palette(n),
              stroke = TRUE, weight = .5) 


leaflet(elementId = "DocksHoodsCountZoomed") |> 
  addTiles() |> 
  addPolygons(data = count_by_neighborhood, opacity = 1,
              color = "black", fillColor = ~dock_palette(n),
              stroke = TRUE, weight = .5) |> 
  setView(lng=-73.85, lat = 40.75, zoom = 11)


leaflet(elementId = "DocksHoodsCountZoomedCarto") |> 
  addProviderTiles('CartoDB.Voyager', dependencyLocation=here()) |> 
  addPolygons(data = count_by_neighborhood, opacity = 1,
              color = "black", fillColor = ~dock_palette(n),
              stroke = TRUE, weight = .5) |> 
  setView(lng=-73.85, lat = 40.75, zoom = 11)



leaflet(elementId = "DocksHoodsCountCartoGL") |> 
  addProviderTiles('CartoDB.Voyager', dependencyLocation=here()) |> 
  addGlPolygons(data = count_by_neighborhood |> st_cast("POLYGON"),
                opacity = 1,fillColor = 'n') |> 
  setView(lng=-73.85, lat = 40.75, zoom = 11)


leaflet(elementId = "DocksHoodsCountCartoGLPoints") |> 
  addProviderTiles('CartoDB.Voyager', 
                   dependencyLocation=here()) |> 
  addGlPolygons(data = count_by_neighborhood |> st_cast("POLYGON"),
                opacity = 1,fillColor = 'n') |> 
  addGlPoints(data = docks) |> 
  setView(lng=-73.85, lat = 40.75, zoom = 11)


# Hex Bins

library(h3jsr)

dock_hex <- docks |> 
  select(start_station_name) |> 
  mutate(hex=h3jsr::point_to_cell(geometry, res=8)) |> 
  st_drop_geometry() |> 
  count(hex) |> 
  h3_to_polygon(simple=FALSE)


dock_hex

leaflet(elementId = 'HexCounts') |> 
  addProviderTiles('CartoDB.Voyager', dependencyLocation=here())
















