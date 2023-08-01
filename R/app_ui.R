#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(

    tags$head(
      shiny::HTML('<meta name="viewport" content="width=device-width,
         initial-scale=1.0,
         maximum-scale=1.0, user-scalable=no" />'),
      includeCSS("style.css")
    ),



    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic


    shiny::navbarPage(
      windowTitle = paste0("REACH", toupper(golem::get_golem_options("country")) ,golem::get_golem_options("assessment_name"),"DASHBOARD"),
      HTML('<a style="padding-left:10px;" class = "navbar-brand" href = "https://www.reach-initiative.org" target="_blank"><img src = "www/reach_logo.png" height = "50"></a><span class="navbar-text" style="font-size: 16px; color: #FFFFFF"><strong>',toupper(golem::get_golem_options("country")), ' ', toupper(golem::get_golem_options("assessment_name")),'DASHBOARD ', golem::get_golem_options("year"), '</strong></span>'),

      mod_introduction_ui("introduction_1"),
      mod_Graph_ui("Graph_1"),
      mod_map_ui("map_1")

    ) ## end navar page


  ) ## end taglost
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "MSNAdashboard"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
