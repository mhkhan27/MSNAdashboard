#' map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_map_ui <- function(id){
  ns <- NS(id)
  tabPanel("Map!",
           icon = shiny::icon("location-dot"),
           shiny::absolutePanel(
             fixed = TRUE,
             width = 500,
             draggable = FALSE,
             top = 110,
             left = 30,
             right = 400,
             class= "well",
             tags$style(".well {background-color:#F2F2F2;}"),
             # if length more than 1
             tags$div(
               class = "ident-picker",
               shinyWidgets::pickerInput(ns("select_pop"),
                                         label = "Select population group:",
                                         choices =  unique(base_file$pop_group),
                                         selected = unique(base_file$pop_group)[1],
                                         multiple = F,
                                         options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
               )),#,style="display:inline-block"),

             tags$div(shinyWidgets::pickerInput(ns("select_sector"),
                                                label = "Select Sector:",
                                                choices =  NULL,
                                                selected = NULL,
                                                multiple = F,
                                                options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             )),


             tags$div(shinyWidgets::pickerInput(ns("select_indicator"),
                                                label = "Select Indicator:",
                                                choices =  NULL, ## Need to add
                                                selected = NULL, ## Need to add
                                                multiple = F,
                                                options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             )),

             tags$div(shinyWidgets::pickerInput(ns("select_choice"),
                                                label = "Select choice:",
                                                choices =  NULL,## Need to add
                                                selected = NULL,## Need to add
                                                multiple = F,
                                                options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             ))


             # tags$div(shinyWidgets::pickerInput(ns("select_admin_level"),
             #                                    label = "Select admin:",
             #                                    choices =  NULL,## Need to add
             #                                    selected = NULL,## Need to add
             #                                    multiple = F,
             #                                    options = shinyWidgets::pickerOptions(title = "Select", actionsBox = TRUE, liveSearch = TRUE)
             # ),style="display:inline-block"),
           ), # end absolute panel
           # br(),
           # hr(),

           shiny::mainPanel(width = 12,
                            div(class = "outer", tags$style(type = "text/css", ".outer {position: fixed; top: 50px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                                leaflet::leafletOutput( ns("map_by_choice"),width = "100%", height = "100%"))


           ) # end mainpane
  ) # end tabpanel
}

#' map Server Functions
#'
#' @noRd
mod_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    base_map <- leaflet::leaflet() |>
      leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron) |>
      leaflet::addPolygons(data = admin_zero_sf,color = "#EE5859",fillColor = "transparent")


    base_file <- base_file |> dplyr::filter(!(grepl("0",admin_level) & stat == 0))

    data_pop <- reactive({base_file |> dplyr::filter(pop_group == input$select_pop)})

    ### sector
    sector_list <- shiny::reactive({
      data_pop()$sector |> unique()

    })
    shiny::observe({
      shinyWidgets::updatePickerInput(session, "select_sector",
                                      choices = sector_list() ,
                                      selected = sector_list()[1])
    })

    data_sector <- reactive({data_pop() |> dplyr::filter(sector == input$select_sector)})




    #### indicator

    indicator_list <-shiny::reactive({
      data_sector()$indicator |> unique()

    })

    shiny::observe({
      shinyWidgets::updatePickerInput(session, "select_indicator",
                                      choices = indicator_list() ,
                                      selected = indicator_list()[1])
    })
    data_indicator<- reactive({data_sector() |> dplyr::filter(indicator == input$select_indicator)})


    ### choice
    choice_list <-shiny::reactive({
      data_indicator()$choice |> unique()

    })

    # choice_label <-shiny::reactive({
    #   data_indicator()$`\`label::English\`_choice` |> unique()
    #
    # })


    shiny::observe({
      shinyWidgets::updatePickerInput(session, "select_choice",
                                      # choices = choice_list() ,
                                      choices = choice_list(),
                                      selected = choice_list()[1])
    })
    data_choice<- reactive({data_indicator() |> dplyr::filter(choice == input$select_choice)})



    #### admin filter
    admin_list <-shiny::reactive({
      data_choice()$admin_level |> unique()

    })

    # shiny::observe({
    #   shinyWidgets::updatePickerInput(session, "select_admin_level",
    #                                   choices = admin_list() ,
    #                                   selected = admin_list()[1])
    # })
    # data <- reactive({data_choice() |> dplyr::filter(admin_level == input$select_admin_level)})

    base_map_2 <- reactive({

      base_map_2 <- base_map

      pal_value <- data_choice()$stat

      for(i in admin_list()){

        data <- reactive({data_choice() |> dplyr::filter(admin_level == i)})


        if(grepl("0",i)){
          map_data <- admin_zero_sf |> dplyr::mutate(
            stat = data()$stat,
            indicator = data()$indicator ,
            choice = data()$choice,
            admin_name = "National")

        }

        if(grepl("1",i)){
          map_data <- admin_one_sf |> dplyr::left_join(data(),by = "admin_name")
        }
        if(grepl("2",i)){
          map_data <- admin_two_sf |> dplyr::left_join(data(),by = "admin_name")
        }

        if(grepl("3",i)){
          map_data <- admin_three_sf |> dplyr::left_join(data(),by = "admin_name")
        }



        pal <- leaflet::colorNumeric("YlOrRd", domain = pal_value)



        base_map_2 <- base_map_2 |>
          leaflet::addPolygons(data = map_data,smoothFactor = .2,
                               fillColor = ~pal(map_data$stat),
                               color = "#58585A",
                               label = ~htmltools::htmlEscape(map_data$stat),
                               labelOptions = leaflet::labelOptions(noHide = F,
                                                                    sticky = T ,
                                                                    textOnly = TRUE,
                                                                    textsize = "11px"),
                               popup = paste(
                                 "<b>Admin name:</b>",map_data$admin_name, "<br>",
                                 "<b>Indicator name:</b>",map_data$indicator, "<br>",
                                 "<b>Choice name:</b>",map_data$choice, "<br>",
                                 "<b>Value:</b>", map_data$stat),
                               weight = 2,dashArray = "3",
                               highlightOptions = leaflet::highlightOptions(weight = 5,
                                                                            color = "#666",
                                                                            dashArray = "",
                                                                            fillOpacity = 0.7,
                                                                            bringToFront = TRUE),
                               group = i)

        ## need to find better alternative
        if(which(admin_list()== i)==length(admin_list())){

          base_map_2 <- base_map_2 |> leaflet::addLegend(data = map_data,
                                                         position = "bottomright",
                                                         pal = pal,
                                                         values = ~stat,
                                                         title = "value",
                                                         opacity = .6
          )

        }


      }

      base_map_2 <- base_map_2 |> leaflet::addLayersControl(
        baseGroups = unique(admin_list()),
        options = leaflet::layersControlOptions(collapsed = FALSE))

      base_map_2
    })

    output$map_by_choice <- leaflet::renderLeaflet({ base_map_2()})
  })
}

## To be copied in the UI
# mod_map_ui("map_1")

## To be copied in the server
# mod_map_server("map_1")
