#' Run the Shiny Application
#'
#' @param country Country Name
#' @param assessment_name Please define the assessment name
#' @param year Year of the assessment
#' @inheritParams shiny::shinyApp
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
#'
#'
#'


## add data and column_name_for_populaion_group in the parameter
create_dashboard <- function(
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    country ,
    assessment_name,
    year,
    ...
) {



  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern

    ),
    golem_opts = list(country= country,
                      assessment_name =assessment_name,
                      year=year,
                      ...)
  )
}
