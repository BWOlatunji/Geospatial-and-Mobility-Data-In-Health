
# rm(list = ls())
# select_data_list <- readRDS("data/select_data.rds")
# hcf_state_names <- select_data_list$hcf_state_names
# hcf_category <- select_data_list$hcf_category

#source("data_scripts/data_prep.R")

er_UI <- function(id, state_vec, hcf_category_vec) {
  ns <- NS(id)
  tagList(fluidPage(
               fluidRow(
                 column(3,
                        textAreaInput(inputId = ns("incidentAddress"),
                                      label = "Incident Address: ",
                                      value = "23 Onitsha Crescent Off Gimbiya Street, Garki 900241, Area 11, Abuja"),
                        textAreaInput(inputId = ns("incidentDesc"),
                                      label = "Describe Incident: ",
                                      value = ""),
                        textInput(inputId = ns("contactPhoneNum"),
                                  label = "Contact Phone Number:",
                                  value = "",
                                  placeholder = "+2348000000000"),
                        numericInput(inputId = ns("sliderNumVictims"),
                                     label = "Number of Victims:",
                                     min = 1, max = 20, value = 1),
                        hr(),
                        selectInput(inputId = ns("incidentState"),
                                    label = "Select State:",
                                    choices = c(Choose='', state_vec),
                                    selected = "Fct"),
                        
                        selectInput(inputId = ns('facilityCategory'), 
                                    label = 'Select Facility Category:',
                                    choices = c(Choose='', hcf_category_vec), 
                                    selectize=TRUE,selected = "Primary Health Center"),
                        actionButton(inputId = ns("erSubmitButton"),
                                     label = "Submit")
                 ),
                 column(9,
                        h3("Closest Health Facilities"),
                        leafletOutput(outputId = ns("nnHCF"))
                 )
               )
             )
  )
}

er_Server <- function(id, dataset) {
  moduleServer(
    id,
    function(input, output, session) {
     
     m <- eventReactive(input$erSubmitButton, {
        
        national_hcf_filtered <- dataset |> 
            filter(state_name == input$incidentState, 
                   category == input$facilityCategory, 
                   functional_status == "Functional") |> 
            select(latitude, longitude,name) |> 
            rowid_to_column(var = "hcf_id")
          
        
        #"Ojota Chemical Market, Ojota, Lagos"
        
        # * Geocoding: Address -> Lat Long ----
        
        # convert to geometry
        inc_locations_latlon_tbl_sf <- geo(input$incidentAddress, 
                                           method = "arcgis") |> 
          st_as_sf(
            coords = c("long", "lat"),
            crs    = 4326
          ) |> 
          left_join(geo(input$incidentAddress, 
                        method = "arcgis")) |> 
          rowid_to_column(var = "inc_id")
        
         
        
        # 3.0 NEAREST NEIGHBORS ----
        # * Alternatively we can use sfnetworks
        # * I'm going to use nngeo
        
        # * Getting Nearest Neighbors with nngeo ----
        
        if(nrow(national_hcf_filtered)<=3){
          network_ids <- st_nn(
            x = inc_locations_latlon_tbl_sf,
            y = national_hcf_filtered, 
            k = nrow(national_hcf_filtered),
            progress = T
          )
        } else{
          network_ids <- st_nn(
            x = inc_locations_latlon_tbl_sf, 
            y = national_hcf_filtered, 
            k = 3,
            #k = nrow(national_hcf_filtered),
            progress = T
          )
        }
  
        network_lines_sf <-st_connect(
            x = inc_locations_latlon_tbl_sf, 
            y = national_hcf_filtered, 
            ids = network_ids
          )
        
        m <- mapview(
          national_hcf_filtered[unlist(network_ids),], 
          col.region = "cyan",
          color      = "white",
          layer.name = "National Hospitals",
          cex        = 12
        )+
          mapview(
            inc_locations_latlon_tbl_sf, 
            col.region = "magenta",
            color      = "white",
            layer.name = "Incident location",
            cex        = 20
          )+
          mapview(
            network_lines_sf,
            color      = "yellow"
          )
        m
      })
      
      output$nnHCF <- renderLeaflet({
        m()@map
      })
    }
  )
}

