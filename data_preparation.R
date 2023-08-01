

  devtools::load_all()
  ### remove all files
  file_list <- list.files("data/",full.names = T)
  unlink(file_list)

  #################################################################################################################
  ############################################### create base file ################################################
  #################################################################################################################

  validated_analysisq <- read.csv("data-raw/validated_analysis/validated_analysis.csv") # read analysis file
  survey <- openxlsx::read.xlsx("data-raw/kobo_tool.xlsx",1)
  choice <- openxlsx::read.xlsx("data-raw/kobo_tool.xlsx",2)
  dapx <- openxlsx::read.xlsx("data-raw/DAP_for_dashboard.xlsx",1)



  base_file <- creating_base_file(validated_analysis =validated_analysisq,analysis_key = "key_index",
                                  kobo_survey = survey,kobo_choice = choice,dap = dapx,dap_sector = "sector",dap_indicator = "indicator")

  # fixing the label

  base_file <- base_file |> dplyr::mutate(
    choice = dplyr::case_when(!is.na(`\`label::English\`_choice`)~ `\`label::English\`_choice`,
                              T~choice)
  )


  usethis::use_data(base_file,overwrite = T)

  #################################################################################################################
  ###################################### Texts for introduction ################################################
  #################################################################################################################

  text_file <- openxlsx::read.xlsx("data-raw/text_file.xlsx",sheet = 2)
  text_file |> usethis::use_data(overwrite = T)

  overview <- text_file |> dplyr::filter(id == "Overview") |> dplyr::pull(details)
  overview |> usethis::use_data(overwrite = T)

  methodology <- text_file |> dplyr::filter(id == "Methodology") |> dplyr::pull(details)
  methodology |> usethis::use_data(overwrite = T)

  limitation <- text_file |> dplyr::filter(id == "Limitations") |> dplyr::pull(details)
  limitation |> usethis::use_data(overwrite = T)

  contact_name <- text_file |> dplyr::filter(id == "Contact_person_name") |> dplyr::pull(details)
  contact_name |> usethis::use_data(overwrite = T)

  contact_email <- text_file |> dplyr::filter(id == "contact_person_email") |> dplyr::pull(details)
  text_file |> usethis::use_data(overwrite = T)

  contact <- paste0("<br><a href = mailto:" , contact_email, ">",contact_name,"</a>")
  contact |> usethis::use_data(overwrite = T)


  ##################################################################################################################
  ###################################### Create data for sharefiles ################################################
  ##################################################################################################################

  admin_three_sf <- sf::st_read("data-raw/admin_boundary/OCHA_renamed_adm3.shp")
  admin_three_sf <- admin_three_sf |> dplyr::rename(
    admin_name = admin3,
    admin_label = admin3Name) |> dplyr::select(admin_name,admin_label) |> dplyr::mutate(
      admin_level = "admin3"
    ) |> rmapshaper::ms_simplify()
  admin_three_sf |> usethis::use_data(overwrite = T)


  admin_two_sf <- sf::st_read("data-raw/admin_boundary/OCHA_renamed_adm2.shp")  |> dplyr::rename(
    admin_name = admin2,
    admin_label = admin2_la)  |> dplyr::mutate(
      admin_level = "admin2"
    ) |> rmapshaper::ms_simplify()
  admin_two_sf |> usethis::use_data(overwrite = T)


  admin_one_sf <- sf::st_read("data-raw/admin_boundary/OCHA_renamed_adm1.shp") |> dplyr::rename(
    admin_name = admin1,
    admin_label = admin1_la)  |> dplyr::mutate(
      admin_level = "admin1"
    ) |> rmapshaper::ms_simplify()

  admin_one_sf |> usethis::use_data(overwrite = T)

  admin_zero_sf <- sf::st_read("data-raw/admin_boundary/OCHA_renamed_adm0.shp") |>
    dplyr::mutate(admin_level = "admin0") |> rmapshaper::ms_simplify()

  admin_zero_sf |> usethis::use_data(overwrite = T)


  ##################################################################################################################
  ###################################### Create sample frame by population group ###################################
  ##################################################################################################################

  sample_frame <- read.csv("data-raw/sample_frame.csv")


  sample_frame_for_dashboard <- create_sample_frame_file(sample_frame = sample_frame,
                                                         base_file = base_file,
                                                         completed_survey = "Number_survery",
                                                         pop_group ="Population.Group" ,
                                                         admin_name = "Strata.name")

  usethis::use_data(sample_frame_for_dashboard,overwrite = T)


  ##################################################################################################################
  ###################################### Create overview map ###################################
  ##################################################################################################################

  overview_map <- create_overview_map(sample_frame_for_dashboard,
                                      admin_one_sf,
                                      admin_two_sf,
                                      admin_three_sf
  )
  usethis::use_data(overview_map,overwrite = T)


  rm(list = ls())
  .rs.restartR()





