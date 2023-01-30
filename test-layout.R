library(shiny)

ui <- fluidPage(
  fluidRow(column(
    12,
    h1("Geospatial and Mobility Data for Health Solutions")
  )),
  fluidRow(column(
    8,
    textAreaInput(
      inputId = "incidentAddress",
      label = "Incident Address: ",
      value = "",
      width = "100%"
    )
  ),
  column(
    4,
    textInput(
      inputId = "contactPhoneNum",
      label = "Contact Phone Number:",
      value = "",
      placeholder = "+2348000000000"
    )
  )),
  fluidRow(column(
    4,
    numericInput(
      inputId = "numVictims",
      label = "Number of Victims:",
      min = 1,
      max = 20,
      value = 1
    )
  ),
  column(
    8,
    textAreaInput(
      inputId = "incidentDesc",
      label = "Describe Incident: ",
      value = "",
      width = "100%"
    )
  )),
  fluidRow(
    hr(),
    column(
      4,
      selectInput(
        inputId = 'facilityCategory',
        label = 'Select Facility Category:',
        choices = c(Choose = '', national_hcf_category),
        selectize = TRUE
      )
    ),
    column(
      4,
      selectInput(
        inputId = "incidentState",
        label = "Select State:",
        choices = c(Choose = '', national_hcf_state_names)
      )
    ),
    column(
      4,
      br(),
      actionButton(inputId = "erSubmitButton",
                   label = "Submit")
    )
  )
  
)

server <- function(input, output, session) {
  
}

shinyApp(ui, server)

