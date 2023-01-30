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

ui <- navbarPage(
  theme = custom_theme,
  title = "Emergency Response and RI Planning",
  tabPanel(title = "Home", 
           p("This Shiny application was created 
           as a health solution for emergency response 
           and routine immunization planning")),
  
  # fill content for tab 2
  
  tabPanel(title = "RI Planning For Pharmacy to PHC",
           fluidPage(
             fluidRow(
               column(3,
                      selectInput("riStates1", 
                                  label = "Select State:",
                                  choices = c(Choose='', national_hcf_state_names), 
                                  selectize=TRUE),
                      
                      hr(),
                      
                      actionButton(inputId = "btnPhPHC",
                                   label = "Submit")
               ),
               column(9,
                      leafletOutput(outputId = "riPhPHCMapRoute")
               )
             )
           )),
  
  tabPanel(title = "RI Planning For PHC to Patients",
           ),
  inverse = T
)


server <- function(input, output, session) {
  
  mPhPHC <- eventReactive(input$btnPhPHC, {
      national_pharmacy <- national_hcf |> 
        filter(state_name == input$riStates1, 
               category == "Pharmacy", 
               functional_status == "Functional") |> 
        select(latitude,longitude,name) |> 
        rowid_to_column(var = "hcf_id")
      
      national_phc <- national_hcf |> 
        filter(state_name == input$riStates1, 
               category == "Primary Health Care", 
               functional_status == "Functional") |> 
        select(latitude,longitude,name) |> 
        rowid_to_column(var = "hcf_id")
      
      # NEAREST NEIGHBORS ----
      # * Alternatively we can use sfnetworks
      # * I'm going to use nngeo
      
      # * Getting Nearest Neighbors with nngeo ----
      
      network_ids <- st_nn(
        x = national_pharmacy, 
        y = national_phc, 
        k = nrow(national_phc),
        progress = T
      )
      
      network_lines_sf <-st_connect(
        x = national_pharmacy, 
        y = national_phc, 
        ids = network_ids
      )
      
      m <- mapview(
        national_phc[unlist(network_ids),], 
        col.region = "cyan",
        color      = "white",
        layer.name = "Primary Health Cares",
        cex        = 12
      )
    m
      })
  
  output$riPhPHCMapRoute <- renderLeaflet({
    mPhPHC()@map
  })
  
}

shinyApp(ui, server)

