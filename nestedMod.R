
library(shiny)

inner_1_UI <- function(id) {
  ns <- NS(id)
  tagList(
    sliderInput(ns("myslide"),
                "slide me",
                min = 0,
                max = 100,
                value = 50
    )
  )
}
inner_1 <- function(id) {
  moduleServer(id, function(input, output, session) {
    reactive({
      req(input$myslide)
    })
  })
}


inner_2_UI <- function(id) {
  ns <- NS(id)
  tagList(
    verbatimTextOutput(ns("outtext"))
  )
}
inner_2 <- function(id, val) {
  moduleServer(id, function(input, output, session) {
    output$outtext <- renderText({
      req(val())
    })
  })
}

outer_UI <- function(id) {
  ns <- NS(id)
  tagList(
    inner_1_UI(ns("1")),
    inner_2_UI(ns("2"))
  )
}

outer <- function(id) {
  moduleServer(id, function(input, output, session) {
    i1 <- inner_1("1")
    inner_2("2", i1)
    
    observeEvent(
      i1(),
      str(i1())
    )
    
  })
}


ui <- fluidPage(
  outer_UI("myouter")
)

server <- function(input, output, session) {
  outer("myouter")
}

shinyApp(ui, server)
