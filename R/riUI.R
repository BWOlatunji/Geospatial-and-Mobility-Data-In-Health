ri_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidPage(
      fluidRow(
        column(3,
               selectInput(ns("riStates"), 
                           label = "Select State:",
                           choices = c(Choose='', national_hcf_state_names), 
                           selectize=TRUE),
               radioButtons(ns("rdRIStep"), 
                            h5("Select Routine Immunization Plan:"),
                            choices = list("Pharmacy to Primary Health Care" = 1, 
                                           "Primary Health Care to Patients" = 2),selected = 1),
               
               actionButton(inputId = ns("riSubmitButton"),
                            label = "Submit"),
               hr()
        ),
        column(9,
               leafletOutput(outputId = "riMapRoute")
        )
      )
    )
  )
}

ri_Server <- function(id) {
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
    }
  )
}