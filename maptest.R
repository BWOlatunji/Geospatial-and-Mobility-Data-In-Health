library(shiny)

ui <- fluidPage(
  fluidRow(column(6,
                  mapviewOutput("breweries")
                  ),
           column(6,
                  mapview("franconia")))
)

server <- function(input, output, session) {
  output$breweries <- renderMapview({
    mapview(breweries)
  })
  
  output$franconia <- renderMapview({
    mapview(franconia)
  })
}

shinyApp(ui, server)