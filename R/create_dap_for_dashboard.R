
#' Function to prepare the DAP for dashboard
#'
#' @param list_of_dataset A list containing all level of data
#' @param column_name_for_populaion_group population group column name
#' @param kobo_survey Kobo survey tab
#' @param sector_name List of sectors
#' @param output_path Excel path for the DAP
#' @return Data Analysis Plan for the Dashboard.
#' @export
#'

write_dap_for_dashboard<- function(list_of_dataset,
                                   column_name_for_populaion_group,
                                   kobo_survey,
                                   sector_name = c("WASH","Food Security","Protection","Livelihood","Education","Health","Nutrition","Shelter","Demographic"),
                                   output_path = "data-raw/DAP_for_dashboard.xlsx"){

  my_bind_row <- get("bind_rows",asNamespace("dplyr"))
  sector_name <- sector_name |> sort()


  ##### add indicator ##########

  indicator_list <- list()

  for( i in names(list_of_dataset)){

    df <- list_of_dataset[[i]] |> as.data.frame()


    df_names <- tibble::tibble(
      main_variable = names(df))

    sm_child_parent <- cleaningtools::auto_sm_parent_children(df) |> dplyr::rename(
      main_variable = sm_parent)

    select_multiple_main_variable <- sm_child_parent |> dplyr::select(main_variable) |> dplyr::distinct()

    indicator_list[[i]] <- df_names |> dplyr::filter(!main_variable %in% sm_child_parent$sm_child ) |>
      dplyr::bind_rows(select_multiple_main_variable) |>
      dplyr::mutate(analysis_level = i)


  }

  dap_for_dashboard <- do.call("my_bind_row",indicator_list)

  # adding label from survey ------------------------------------------------

  data_diagnosis_result <- list()

  survey_to_add <- kobo_survey |> dplyr::select(name,starts_with("label")) |> dplyr::rename(main_variable = name)

  dap_for_dashboard <- dap_for_dashboard |> dplyr::left_join(survey_to_add,by = "main_variable")

  dap_for_dashboard <- dap_for_dashboard |> dplyr::mutate(
    sector = "",
    indicator = ""
  ) |> dplyr::select(sector,indicator,dplyr::starts_with("lable"),main_variable,dplyr::everything())


  ################################# Start::Meta data input ###################################################

  for(i in names(list_of_dataset)){
    pop2 <- tryCatch(list_of_dataset[[i]][[column_name_for_populaion_group]] |> unique() ,
                     error = function(cond) {return(NA)})
    if(!is.null(pop2)){pop <- pop2}

  }


  # write diagnosis ---------------------------------------------------------


  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "dap_for_dashboard")
  openxlsx::addWorksheet(wb, "sector_name")



  openxlsx::writeDataTable(wb, "dap_for_dashboard", x = dap_for_dashboard)
  openxlsx::writeDataTable(wb, "sector_name", x = sector_name |> as.data.frame())

  openxlsx::sheetVisibility(wb)[2] <- F

  row_numbers <- 1:nrow(dap_for_dashboard)+1

  openxlsx::dataValidation(wb, sheet = "dap_for_dashboard", cols  = 1, rows = row_numbers, type = "list", value = "'sector_name'!$A$2:$A$10")


  openxlsx::saveWorkbook(wb, output_path, overwrite = TRUE)


}




# #################################################################################################
#
#
#
# library(readxl)
# library(stringr)
# library(tidyverse)
# library(openxlsx)
#
#
# illuminate::read_sheets("data-raw/cleaned_data/cleaned_data.xlsx")
# illuminate::read_sheets("data-raw/kobo_tool.xlsx")
#
# list_of_dataset <- list(
#   HH_data = HH_data,
#   INDV_data = INDV_data
# )
#
# #
# write_dap_for_dashboard(list_of_dataset = list_of_dataset,
#                         kobo_survey = survey,
#                         column_name_for_populaion_group = "pop_group")
#


