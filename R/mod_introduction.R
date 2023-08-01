#' introduction UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_introduction_ui <- function(id){
  ns <- NS(id)
  shiny::tabPanel("Overview",
                  icon = shiny::icon("chart-bar"),

                  br(),
                  shiny::mainPanel(width = 12,
                  shiny::column(width = 8,
                                h4(strong("Overview:"),   HTML(paste(overview))),
                                hr(),
                                h4(strong("Methodology:"),   HTML(paste(methodology))),
                                hr(),
                                h4(strong("Limitation:"),   HTML(paste(limitation))),
                                hr(),
                                h4(strong("Contact:"),   HTML(paste(contact))),

                  ), ## end column 1
                  shiny::column(width = 4,
                        leaflet::leafletOutput( ns("overview_map"))
                  )# end column 2
) # end main panel
  ) # end tabpanel
}

#' introduction Server Functions
#'
#' @noRd
mod_introduction_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$overview_map <- leaflet::renderLeaflet({
      overview_map
    })

  })
}

## To be copied in the UI
# mod_introduction_ui("introduction_1")

## To be copied in the server
# mod_introduction_server("introduction_1")
