#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic


  mod_introduction_server("introduction_1")
  mod_Graph_server("Graph_1")
  mod_map_server("map_1")

}
