

library(bslib)
library(shiny)
library(bsicons)

library(DT)
library(thematic)


library(mapview)
library(sf)
library(leaflet)


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
                      "content 1"),
  
  # fill content for tab 2
  tabPanel(title = "Emergency Response",
           fluidPage(
             fluidRow(
               column(3,
                 textAreaInput(inputId = "incidentAddress",
                               label = "Incident Address: ",
                               value = ""),
                 textAreaInput(inputId = "incidentDesc",
                               label = "Describe Incident: ",
                               value = ""),
                 textInput(inputId = "contactPhoneNum",
                           label = "Contact Phone Number:",
                           value = "",
                           placeholder = "+2348000000000"),
                 numericInput(inputId = "sliderNumVictims",
                              label = "Number of Victims:",
                             min = 1, max = 20, value = 1),
                 hr(),
                 selectInput(inputId = "incidentState",
                             label = "Select State:",
                             choices = c(Choose='', national_hcf_state_names)),
                 
                 selectInput(inputId = 'facilityCategory', 
                             label = 'Select Facility Category:',
                             choices = c(Choose='', national_hcf_category), 
                             selectize=TRUE),
                 actionButton(inputId = "erSubmitButton",
                              label = "Submit")
               ),
               column(9,
                 h3("Closest Health Facilities"),
                 leafletOutput(outputId = "nnHCF")
               )
             )
           )),
  
  tabPanel(title = "RI Planning",
           fluidPage(
               fluidRow(
                 column(3,
                        selectInput("riStates", 
                                    label = "Select RI State:",
                                    choices = c(Choose='', national_hcf_state_names), 
                                    selectize=TRUE),
                        actionButton(inputId = "riSubmitButton",
                                     label = "Submit"),
                        hr()
                 ),
                 column(9,
                        leafletOutput(outputId = "riMapRoute")
                 )
               )
           )),
             inverse = T
  )


server <- function(input, output, session) {
  
  output$nnHCF <- renderLeaflet({
    m <- mapview(
      national_hcf_filtered[unlist(network_ids),], #berlin_customers_sf,
      col.region = "cyan",
      color      = "white",
      layer.name = "National Hospitals",
      cex        = 12
    )+
      mapview(
        inc_locations_latlon_tbl_sf, #berlin_distributors_sf,
        col.region = "magenta",
        color      = "white",
        layer.name = "Incident location",
        cex        = 20
      )+
      mapview(
        network_lines_sf,
        color      = "yellow"
      )
    
    m@map
    
    
  })
  
}


shinyApp(ui = ui, server = server)




