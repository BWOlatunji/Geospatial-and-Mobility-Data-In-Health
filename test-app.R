library(shiny)
library(shinydashboard)
library(mapview)

ui <- dashboardPage(
  dashboardHeader(title = "test"),
  dashboardSidebar(),
  dashboardBody(
    mapviewOutput("map")
  )
)

server <- function(input, output) {
  # output$map <- renderMapview({
  #   mapview(breweries)
  # })
  
  output$map<-renderLeaflet({
    mapview::mapview2leaflet(mapview(national_hcf_filtered))
  })
  
}

shinyApp(ui, server)