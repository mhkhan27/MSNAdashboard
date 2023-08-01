#' Graph UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_Graph_ui <- function(id){
  ns <- NS(id)
  tabPanel("Graph!",
           icon = shiny::icon("chart-area"),

           br(),
           shiny::sidebarPanel(
             tags$style(".well {background-color:#F2F2F2;}"),
             width = 12,
             # if length more than 1
             tags$div(
               class = "ident-picker",
               shinyWidgets::pickerInput(ns("select_pop"),
                                         label = "Select population group:",
                                         choices =  unique(base_file$pop_group),
                                         selected = unique(base_file$pop_group)[1],
                                         multiple = F,
                                         options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
               ),style="display:inline-block"),


             # shinyWidgets::pickerInput(ns("select_analysis_level"),
             #                           label = "Select analysis level:",
             #                           choices =  ,
             #                           selected = ,
             #                           multiple = F,
             #                           options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             # ),style="display:inline-block"),


             tags$div(shinyWidgets::pickerInput(ns("select_admin_name"),
                                                label = "Select Admin name:",
                                                choices =  NULL,
                                                selected = NULL,
                                                multiple = F,
                                                options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             ),style="display:inline-block"),


             tags$div(shinyWidgets::pickerInput(ns("select_sector"),
                                                label = "Select Sector:",
                                                choices =  NULL,
                                                selected = NULL,
                                                multiple = F,
                                                options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             ),style="display:inline-block"),


             tags$div(shinyWidgets::pickerInput(ns("select_indicator"),
                                                label = "Select Indicator:",
                                                choices =  NULL,
                                                selected = NULL,
                                                multiple = F,
                                                options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             ),style="display:inline-block"),
           ), # end slidebar
           hr(),
           shiny::mainPanel(width = 12,

                            plotly::plotlyOutput(ns("pie"))
           )# end mainpanel

  ) # end tabpanel
}

#' Graph Server Functions
#'
#' @noRd
mod_Graph_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # dashboard_input <- golem::get_golem_options("dashboard_input")

    base_file_2 <- base_file |> dplyr::filter(analysis_type  %in% c("prop_select_multiple","prop_select_one"))


    data_pop <- reactive({base_file_2 |> dplyr::filter(pop_group == input$select_pop)})

    #### admin filter
    admin_list <-shiny::reactive({
      data_pop()$admin_name |> unique()

    })

    shiny::observe({
      shinyWidgets::updatePickerInput(session, "select_admin_name",
                                      choices = admin_list() ,
                                      selected = admin_list()[1])
    })

    # admin_selected <- shiny::reactive({input$select_admin_name})

    ## sector list

    data_pop_admin <- reactive({data_pop() |> dplyr::filter(admin_name == input$select_admin_name)})

    sector_list <-shiny::reactive({
      data_pop_admin()$sector |> unique()

    })


    shiny::observe({
      shinyWidgets::updatePickerInput(session, "select_sector",
                                      choices = sector_list() ,
                                      selected = sector_list()[1])
    })



    sector_selected <- shiny::reactive({input$select_sector})

    indicator_list <- shiny::reactive({
      data_pop()[data_pop()$sector == sector_selected(),"indicator"] |> unique()

    })

    ####################### available indicator name in the selected governorate ############


    shiny::observe({
      shinyWidgets::updatePickerInput(session, "select_indicator",
                                      choices = indicator_list() ,
                                      selected = indicator_list()[1])
    })




    ## Apply filter

    dash_df <- reactive({

      base_file |> dplyr::filter(pop_group == input$select_pop &
                                   sector == input$select_sector &
                                   indicator == input$select_indicator &
                                   admin_name == input$select_admin_name)

    })



    output$pie <- plotly::renderPlotly ({




      if( dash_df()$analysis_type[1] == "prop_select_one" & !is.na( dash_df()$analysis_type[1]) &
          length(dash_df()$choice) <6){
        plotly::plot_ly() |> plotly::add_trace(hole = .6,type = "pie",
                                               labels = dash_df()$choice,
                                               values= dash_df()$stat,
                                               showlegend =T) |>
          plotly::layout(title =  unique(dash_df()$indicator),
                         legend = list(orientation = 'h',
                                       xanchor = "center",
                                       x = 0.5))
      }


      else if( dash_df()$analysis_type[1] == "prop_select_one" & !is.na( dash_df()$analysis_type[1]) &
               length(dash_df()$choice) >5){

        ## Barchart
        plotly::plot_ly(data = dash_df(),height = 500,
                        type = "bar",
                        y = ~choice,
                        x= ~stat,
                        texttemplate = '%{x}', textposition = 'outside',
                        marker = list(color = "#585858")) |>
          plotly::layout(title =  list(text =  paste0("<b>",unique(dash_df()$indicator,"</b>")),font = title_style),
                         yaxis = list(title = "",categoryorder = "total ascending"),
                         xaxis = list(title = "",ticksuffix = "%"))
      }




      else if( dash_df()$analysis_type[1] == "prop_select_multiple" & !is.na(dash_df()$analysis_type[1])){

        ## Barchart
        plotly::plot_ly(data = dash_df(),height = 500,
                        type = "bar",
                        y = ~choice,
                        x= ~stat,
                        texttemplate = '%{x}', textposition = 'outside',
                        marker = list(color = "#585858")) |>
          plotly::layout(title =  list(text =  paste0("<b>",unique(dash_df()$indicator,"</b>")),font = title_style),
                         yaxis = list(title = "",categoryorder = "total ascending"),
                         xaxis = list(title = "",ticksuffix = "%"),
                         annotations = list(text = "<i>Note: This is a multiple choice question,<br>the percentages can add up to more than 100%.</i>",
                                            x = max(dash_df()$stat,na.rm = T), y=1 ,showarrow=FALSE ))
      }



    })

    ## find analysis type

    ## bar chart if select multiple

    ## pie chart if select one

    ## integer??



  })
}

## To be copied in the UI
# mod_Graph_ui("Graph_1")

## To be copied in the server
# mod_Graph_server("Graph_1")
