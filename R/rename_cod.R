
#' Function to write renamed OCHA boundaries which would align with dataset
#'
#' @param ocha_cod_level_3 Admin 3 level shape file. Can be downloaded by `download_hdx_adm()`
#' @param cod_admin1_name Admin 1 column name
#' @param cod_admin2_name Admin 2 column name
#' @param cod_admin3_name Admin 3 column name
#' @param mistached_list Filled output from `write_mismatched_strata()`
#' @param output_path Output path
#' @return Write mismatched strata
#' @export
#'




write_renamed_ocha_admin_name <- function(
    ocha_cod_level_3 = cntry_adm_3,
    cod_admin1_name,
    cod_admin2_name,
    cod_admin3_name,
    mistached_list,
    output_path = "data-raw/admin_boundary/OCHA_renamed_adm3.shp") {



  ocha_cod_level_3_only <- ocha_cod_level_3 |> dplyr::mutate(
    admin1 = snakecase::to_snake_case(!!rlang::sym(cod_admin1_name)),
    admin2 = snakecase::to_snake_case(!!rlang::sym(cod_admin2_name)),
    admin3 = snakecase::to_snake_case(!!rlang::sym(cod_admin3_name)),
    admin1_la = !!rlang::sym(cod_admin1_name),
    admin2_la = !!rlang::sym(cod_admin2_name),
    admin3_la = !!rlang::sym(cod_admin3_name)

  ) |> as.data.frame()


  mistached_list <- mistached_list |> dplyr::mutate(
    column_name = dplyr::case_when(level == "admin1" ~cod_admin1_name,
                                   level == "admin2" ~ cod_admin2_name,
                                   level == "admin3" ~ cod_admin3_name
    )
  )


  for (i in 1:nrow(mistached_list)) {

    ocha_cod_level_3_only[[ mistached_list[i,][["level"]]]] <- dplyr::if_else(ocha_cod_level_3_only[[ mistached_list[i,][["level"]]]] == mistached_list[i,][["ocha_cod_name"]],
                                                                              mistached_list[i,][["df_admin_name"]],
                                                                              ocha_cod_level_3_only[[ mistached_list[i,][["level"]]]])

  }

  sf::st_write(ocha_cod_level_3_only,output_path)

}


# write_renamed_ocha_admin_name(ocha_cod_level_3 = cntry_adm_3,
#                               cod_admin1_name = "admin1Name",
#                               cod_admin2_name = "admin2Name",
#                               cod_admin3_name = "admin3Name",
#                               mistached_list = mistached_list,
#                               output_path = "data-raw/OCHA_renamed_adm3.shp")


