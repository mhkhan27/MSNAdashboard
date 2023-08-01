

#' Title
#'
#' @param validated_analysis Analysis file in long format. This file must have stat,key_index,admin_level,admin_name column
#' @param stat  stat column name in the analysis file
#' @param analysis_key Analysis key name in the analysis file
#' @param kobo_survey Kobo survey
#' @param kobo_choice Kobo choice
#' @param dap Data analysis file. Must be the output file from `create_dap`.
#' @param dap_sector Sector name in the DAP
#' @param dap_indicator Indicator name in the DAP
#'
#' @return
#' @export
#'

creating_base_file <- function(validated_analysis,
                               stat="stat",
                               pop_group = "pop_group",
                               admin_name = "admin_name",
                               admin_level = "admin_level",
                               analysis_key,
                               kobo_survey,
                               kobo_choice,
                               dap,
                               dap_sector,
                               dap_indicator){


  # if(any(!c(stat,pop_group,admin_name,admin_level,analysis_key) %in% names(validated_analysis))){
  #   stop("`admin_name`,`admin_level`,`pop_group` must be present in the analysis file.")
  # }
  #


  # renaming ---------------------------------------------------------------

  dap <- dap |> dplyr::rename(
    sector = !!rlang::sym(dap_sector),
    indicator = !!rlang::sym(dap_indicator),
  )

  validated_analysis <- validated_analysis |> dplyr::rename(
    key_index = !!rlang::sym(analysis_key),
    stat = !!rlang::sym(stat),
    admin_name = !!rlang::sym(admin_name),
    admin_level = !!rlang::sym(admin_level),
    pop_group = !!rlang::sym(pop_group)
  )

  # Filter dap to keep only need ones ----------------------------------

  dap <- dap |> dplyr::select(-dplyr::contains("label::"))
  if(any((is.na(dap$sector) & !is.na(dap$indicator)) |
         (!is.na(dap$sector) & is.na(dap$indicator)))){warning("Please review the idicators/Sector as either... ")}

  dap <- dap  |> dplyr::filter(!is.na(sector) & !is.na(indicator))



  # Extract information from key index --------------------------------------


  key_table <- presentresults::create_analysis_key_table(.results = validated_analysis,analysis_key = "key_index") |>
    dplyr::select(c("key_index", "analysis_type", "analysis_var_1", "analysis_var_value_1"))

  ## Renaming
  validated_analysis <- validated_analysis |> dplyr::left_join(key_table) |> dplyr::rename(
    main_variable = analysis_var_1,
    choice = analysis_var_value_1
  )



  # adding questions and choices Label to validated analysis ---------------------------------------

  kobo_choice <- kobo_choice|>
    dplyr::select(c("list_name","name",dplyr::contains("label::")))%>%
    dplyr::rename_if(startsWith(names(.), "label::"), ~paste0(.,"_choice")) |> dplyr::rename(
      choice  = name)

  kobo_survey <- kobo_survey |> dplyr::filter(grepl(" ",type))
  kobo_survey$type <-  sub("^\\S+\\s+", '', kobo_survey$type)
  kobo_survey <- kobo_survey |> dplyr::select(type,name,dplyr::contains("label")) %>%
    dplyr::rename_if(startsWith(names(.), "label::"), ~paste0(.,"_question")) |> dplyr::rename(
      main_variable = name
    )
  kobo <- kobo_survey |> dplyr::left_join(kobo_choice,by = c("type" = "list_name"),relationship = "many-to-many")
  kobo <- kobo |> dplyr::select(-type) |> dplyr::distinct()

  ## Add label to validated analysis
  validated_analysis_joined <- validated_analysis |> dplyr::left_join(kobo)



  # Check if all the required variables from DAP are exists in validated analysis -------------------------------------------------------------------------

  if(any(!dap$main_variable %in% validated_analysis_joined$main_variable)){ warning(
    dap$main_variable[!dap$main_variable %in% validated_analysis_joined$main_variable] |> glue::glue_collapse(",") %>%
      glue::glue("The following variables was not found in the analysis file but exists in dap.The function currently ignoring them.")
  )}


  # Add information from dap [ adding sector, indicator etc] ----------------


  validated_analysis_dap <- validated_analysis_joined |> dplyr::filter(main_variable %in% dap$main_variable) |>
    dplyr::left_join(dap)

  validated_analysis_dap

}

#
# # validated analysis  -----------------------------------------------------
#
