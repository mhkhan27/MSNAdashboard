# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file


# delete everything from data-raw
# Make a copy to your data and tool in the data-raw

rm(list = ls())


new_run <- c(T,F)[2]

if(new_run ==T){
source("data_preparation.R") ### please review this script before running the line. You might need to change some line based on your dataset.
}


# prepare dashboard -------------------------------------------------------

shiny::shinyOptions(cache = cachem::cache_disk())

pkgload::load_all(export_all = FALSE,helpers = FALSE,
                  attach_testthat = FALSE)

options( "golem.app.prod" = TRUE)

MSNAdashboard::create_dashboard(country = "lebanon",
                                        assessment_name =  "MsNa",
                                        year = 2024) # add parameters here (if any)

