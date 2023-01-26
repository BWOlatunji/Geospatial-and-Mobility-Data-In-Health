
library(bslib)
library(shiny)
library(bsicons)

library(DT)
library(thematic)

library(osmdata)    # Open Street Map Overpass API
library(osrm)       # Open Street Map Routing API

library(sf)         # Simple Features
library(nngeo)      # Nearest Neighbors
library(mapview)    # Interactive Maps
library(leaflet)
library(tidygeocoder) # Used for geocoding

library(tidyquant)  # Finance... Because why not?
library(tidyverse)  # Core tidy libs


custom_theme <- bs_theme(
  version = 5,
  bg = "#FFFFFF",
  fg = "#000000",
  primary = "#0199F8",
  secondary = "#FF374B",
  base_font = "Maven Pro"
)


# main dataset
national_hcf  <- st_read("data/national-health-care-facilities/health-care-facilities-primary-secondary-and-tertiary.geojson") #|> 


# selectIput data
selectInput_data <- readRDS(file = "select_item_data.rds")




ui <- navbarPage(
  theme = custom_theme,
  title = "Emergency Response and RI Planning",
  tabPanel(title = "Home", 
           p("This Shiny application was created 
           as a health solution for emergency response 
           and routine immunization planning")),
  
  # fill content for tab 2
  
  tabPanel(title = "Emergency Response",
  er_UI("er_tabpage",state_vec=selectInput_data$state_values, 
        hcf_category_vec=selectInput_data$category_values)),
  
  tabPanel(title = "RI Planning",
           ),
  inverse = T
)


server <- function(input, output, session) {
  
  er_Server("er_tabpage", dataset=national_hcf)
  
}


shinyApp(ui = ui, server = server)




