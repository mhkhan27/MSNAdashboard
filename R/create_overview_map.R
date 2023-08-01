#' Title
#'
#' @param sample_frame_for_dashboard Sample frame data create by `create_sample_frame_file`
#' @param admin_one_sf admin boundary one
#' @param admin_two_sf admin boundary two
#' @param admin_three_sf admin boundary three
#'
#' @return
#' @export
#'
#' @examples
create_overview_map <- function(sample_frame_for_dashboard,
                                admin_one_sf,
                                admin_two_sf,
                                admin_three_sf
                                ){



  bins <- c(0, 10, 20, 50, 100, 200, 500, Inf)
  base_map <- leaflet::leaflet() |>
    leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron) |>
    leaflet::addPolygons(data = admin_zero_sf,color = "#EE5859",fillColor = "transparent")

  overview_map <- base_map
  #
  for(i in unique(sample_frame_for_dashboard$pop_group)){
    df <- sample_frame_for_dashboard[sample_frame_for_dashboard$pop_group ==i,]
    admin_label <-  df$admin_level |> unique()

    dom <- df |> dplyr::filter(!is.na(completed_survey)) |> dplyr::pull(completed_survey)
    pal <- leaflet::colorBin("YlOrRd", domain =dom , bins = bins,na.color = "#585858")


    if(grepl("3",admin_label)){
      df$admin_name[!df$admin_name %in% admin_three_sf$admin_name] |> glue::glue_collapse(", ") %>%
        glue::glue(.," these names are not present in the `admin_three_sf`")

      admin_3_joined <-  admin_three_sf |> dplyr::left_join(df,by = c( "admin_name"="admin_name"))

      overview_map <- overview_map |>
        leaflet::addPolygons(data = admin_3_joined,color = "#58585A",
                             label = ~htmltools::htmlEscape(admin_name),
                             labelOptions = leaflet::labelOptions(noHide = F,
                                                                  sticky = T ,
                                                                  textOnly = TRUE,
                                                                  textsize = "11px"),
                             popup = paste( "<b>",admin_3_joined$admin_name, "</b><br>",
                                            "<b>Number of survey:</b>", admin_3_joined$completed_survey),
                             weight = 2,dashArray = "3",fillColor = ~pal(admin_3_joined$completed_survey),
                             highlightOptions = leaflet::highlightOptions(weight = 5,
                                                                          color = "#666",
                                                                          dashArray = "",
                                                                          fillOpacity = 0.7,
                                                                          bringToFront = TRUE),
                             group =i)


    }

    if(grepl("2",admin_label)){
      df$admin_name[!df$admin_name %in% admin_two_sf$admin_name] |> glue::glue_collapse(", ") %>%
        glue::glue(.," these names are not present in the `admin_two_sf`")

      admin_2_joined <-  admin_two_sf |> dplyr::left_join(df,by = c( "admin_name"="admin_name"))



      overview_map <- overview_map |>
        leaflet::addPolygons(data = admin_2_joined,color = "#58585A",
                             label = ~htmltools::htmlEscape(admin_name),
                             labelOptions = leaflet::labelOptions(noHide = F,
                                                                  sticky = T ,
                                                                  textOnly = TRUE,
                                                                  textsize = "11px"),
                             popup = paste( "<b>",admin_2_joined$admin_name, "</b><br>",
                                            "<b>Number of survey:</b>", admin_2_joined$completed_survey),
                             weight = 2,dashArray = "3",fillColor = ~pal(admin_2_joined$completed_survey),
                             highlightOptions = leaflet::highlightOptions(weight = 5,
                                                                          color = "#666",
                                                                          dashArray = "",
                                                                          fillOpacity = 0.7,
                                                                          bringToFront = TRUE),
                             group =i)

    }

    if(grepl("1",admin_label)){
      df$admin_name[!df$admin_name %in% admin_one_sf$admin_name] |> glue::glue_collapse(", ") %>%
        glue::glue(.," these names are not present in the `admin_one_sf`")

      admin_1_joined <-  admin_one_sf |> dplyr::left_join(df,by = c( "admin_name"="admin_name"))



      overview_map <- overview_map |>
        leaflet::addPolygons(data = admin_1_joined,color = "#58585A",
                             label = ~htmltools::htmlEscape(admin_name),
                             labelOptions = leaflet::labelOptions(noHide = F,
                                                                  sticky = T ,
                                                                  textOnly = TRUE,
                                                                  textsize = "11px"),
                             popup = paste( "<b>",admin_1_joined$admin_name, "</b><br>",
                                            "<b>Number of survey:</b>", admin_1_joined$completed_survey),
                             weight = 2,dashArray = "3",fillColor = ~pal(admin_1_joined$completed_survey),
                             highlightOptions = leaflet::highlightOptions(weight = 5,
                                                                          color = "#666",
                                                                          dashArray = "",
                                                                          fillOpacity = 0.7,
                                                                          bringToFront = TRUE),
                             group =i)
    }

    overview_map <- overview_map |> leaflet::addLayersControl(
      baseGroups = unique(sample_frame_for_dashboard$pop_group),
      options = leaflet::layersControlOptions(collapsed = FALSE))

  }

  overview_map

}
