
#' Function write mismatched strata
#'
#' @param ocha_cod_level_3 Admin 3 level shape file. Can be downloaded by `download_hdx_adm()`
#' @param cod_admin1_name Admin 1 column name
#' @param cod_admin2_name Admin 2 column name
#' @param cod_admin3_name Admin 3 column name
#' @param strata_checking_sheet strata checking sheet, can be found once you run `write_dap_for_dashboard()`
#' @param hh_data HH data
#' @param pop_group_in_validated_analysis Column name in `hh_data` containing population group information.
#' @param output_path Output path
#' @return Write mismatched strata
#' @export
#'




write_mismatched_strata <- function(
    ocha_cod_level_3 =   cntry_adm_3,
    cod_admin1_name= "ADM1_EN",
    cod_admin2_name = "ADM2_EN",
    cod_admin3_name = "ADM3_EN",
    hh_data,
    hh_data_strata_name = "stratification",
    pop_group_in_hh_data = "pop_group",
    # strata_checking_sheet,
    validated_analysis,
    pop_group_in_validated_analysis = "pop_group",
    admin_level_in_validated_analysis = "admin_level",
   output_path="data-raw/admin_mismatch_fix.xlsx"){





  strata_checking_sheet <-validated_analysis |> dplyr::select(pop_group_in_validated_analysis,
                                                              admin_level_in_validated_analysis) |> unique() |>
    dplyr::filter(!grepl("0",admin_level))


  ##### error messege

  if(any(!strata_checking_sheet[[pop_group_in_validated_analysis]] %in%
         hh_data[[pop_group_in_hh_data]])){
    stop(
  strata_checking_sheet[[pop_group_in_validated_analysis]][!strata_checking_sheet[[pop_group_in_validated_analysis]] %in%
                                                             hh_data[[pop_group_in_hh_data]]]  |>
    glue::glue_collapse(", ") %>% glue::glue(., " was found in validated analysis but not found in the dataset ")

    )
  }


  if(any(! unique(hh_data[[pop_group_in_hh_data]]) %in% strata_checking_sheet[[pop_group_in_validated_analysis]])){

    stop(
    unique(hh_data[[pop_group_in_hh_data]])[! unique(hh_data[[pop_group_in_hh_data]]) %in%
                                      strata_checking_sheet[[pop_group_in_validated_analysis]]]  |>
      glue::glue_collapse(", ") %>% glue::glue(., " was found in validated analysis but not found in the dataset ")

    )}




  ######





  my_bind_row <- get("bind_rows",asNamespace("dplyr"))


  ocha_cod_level_3_only <- ocha_cod_level_3 |> dplyr::mutate(
    admin1 = snakecase::to_snake_case(!!rlang::sym(cod_admin1_name)),
    admin2 = snakecase::to_snake_case(!!rlang::sym(cod_admin2_name)),
    admin3 = snakecase::to_snake_case(!!rlang::sym(cod_admin3_name))

  ) |> as.data.frame() |> dplyr::select(admin1,admin2,admin3)

  ocha_cod_level_3_validation <- list(
    admin1 = ocha_cod_level_3_only$admin1|> unique(),
    admin2 = ocha_cod_level_3_only$admin2|> unique(),
    admin3 = ocha_cod_level_3_only$admin3|> unique())




  ### checking BY GROUP
  hh_strata_check_not_found <- list()
  for (i in strata_checking_sheet[[pop_group_in_validated_analysis]]) {


    df_filtered <- hh_data |> dplyr::filter(!!rlang::sym(pop_group_in_validated_analysis) == i)

    strata_checking_filter <- strata_checking_sheet |> dplyr::filter(!!rlang::sym(pop_group_in_validated_analysis) ==i)
    p_group <- strata_checking_filter[[pop_group_in_validated_analysis]]
    strata <- df_filtered[[hh_data_strata_name]]
    admin_level <- strata_checking_filter$admin_level

    if((i != unique(df_filtered[[pop_group_in_validated_analysis]]))){stop("ERROR HERE!")}

    hh_strata_check_not_found[[i]] <- tibble::tibble(
      df_admin_name= unique(df_filtered[[hh_data_strata_name]]),
      level = admin_level
    ) |> dplyr::filter(!df_admin_name %in% ocha_cod_level_3_only[[admin_level]])

  }


  strata_list_not_found <- do.call("my_bind_row",hh_strata_check_not_found) |> dplyr::distinct() |> dplyr::mutate(
    ocha_cod_name = ""
  ) |> dplyr::select(df_admin_name, ocha_cod_name,level)



  ################################ wrtie excel ##########################

  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "strata_list_not_found")
  openxlsx::addWorksheet(wb, "admin1")
  openxlsx::addWorksheet(wb, "admin2")
  openxlsx::addWorksheet(wb, "admin3")



  openxlsx::writeDataTable(wb, 1, x = strata_list_not_found)
  openxlsx::writeDataTable(wb, "admin1", x = ocha_cod_level_3_validation$admin1 |> sort() |> as.data.frame())
  openxlsx::writeDataTable(wb, "admin2", x = ocha_cod_level_3_validation$admin2 |> sort() |> as.data.frame())
  openxlsx::writeDataTable(wb, "admin3", x = ocha_cod_level_3_validation$admin3 |> sort() |> as.data.frame())

  openxlsx::sheetVisibility(wb)[2] <- F
  openxlsx::sheetVisibility(wb)[3] <- F
  openxlsx::sheetVisibility(wb)[4] <- F


  for(i in unique(strata_list_not_found$level)){
    row_numbers <- which(strata_list_not_found$level == i,arr.ind = T)
    sheet_row <-ocha_cod_level_3_validation[[i]] |> length() +1
    openxlsx::dataValidation(wb, 1, col = 2, rows = row_numbers+1, type = "list", value = paste0("'",i,"'","!$A$2:$A$",sheet_row))

  }


  openxlsx::saveWorkbook(wb, output_path, overwrite = TRUE)

}


###########################################################################################################################

# cntry_adm_3 <- MSNAdashboardTemplate::download_hdx_adm(country_code = "lbn",admin_level = 3)

 cntry_adm_3 <- sf::st_read("data-raw/admin_boundary/OCHA_renamed_adm3.shp")


# strata_checking <- readxl::read_excel("data_diagnosis.xlsx",sheet = "strata_checking")
df <- readxl::read_excel("data-raw/cleaned_data/cleaned_data.xlsx",sheet = "HH_data")
#
df <- df |> dplyr::mutate(
  pop_group = dplyr::case_when(pop_group == "lebanese" ~ "Lebanese",
                               pop_group == "migrant" ~ "Migrant",
                               pop_group == "prl" ~ "Palestine Refugees from Lebanon")
)

#
#
#
# write_mismatched_strata(ocha_cod_level_3 = cntry_adm_3,
#                         cod_admin1_name = "admin1Name",
#                         cod_admin2_name = "admin2Name",
#                         cod_admin3_name = "admin3Name",
#                         validated_analysis = base_file,
#                         admin_level_in_validated_analysis = "admin_level",
#                         hh_data=df,output_path = "C.xlsx",
#                         pop_group_in_validated_analysis = "pop_group" )

#
#
#
# ocha_cod_level_3 = cntry_adm_3
# cod_admin1_name = "admin1Name"
# cod_admin2_name = "admin2Name"
# cod_admin3_name = "admin3Name"
# strata_checking_sheet = "strata_checking"
# pop_group_in_validated_analysis = "pop_group"


