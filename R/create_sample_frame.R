#
# create_number_of_survey_by_stratification <- function(
    # HH_Data,
# HH_consent_col = "consent",
# HH_data_consent_yes = "yes",
# HH_data_pop_col = "pop_group",
# HH_data_admin_name = "stratification"){
#
#
# HH_data<- openxlsx::read.xlsx("data-raw/cleaned_data/cleaned_data.xlsx",sheet = "HH_data") ## HH data
# HH_data <- HH_data |> dplyr::filter(!!rlang::sym(HH_consent_col) == HH_data_consent_yes) ### need to adjust the consent
#
# HH_data <- HH_data |> dplyr::rename(
#   pop_group = !!rlang::sym(HH_data_pop_col),
#   admin_name = !!rlang::sym(HH_data_admin_name)
# )
# HH_data |> dplyr::group_by(pop_group,admin_name) |> dplyr::summarise(
#   completed_survey = dplyr::n()
# )
# }




# you can have the sample_frame by using `cleaningtools::review_sample_frame_with_dataset`
# sample_frame<- read.csv("data-raw/sample_frame.csv")



#' Create sample frame file
#'
#' @param sample_frame Sample frame. You can use `cleaningtools::review_sample_frame_with_dataset` to create the file.
#' @param completed_survey Column name for completed survey
#' @param pop_group Column name for population group
#' @param admin_name Column name for Adming name
#'
#' @return Creates a data file
#' @export


create_sample_frame_file <- function(
    sample_frame,
    base_file,
    completed_survey = "Number_survey",
    pop_group= "Population.Group",
    admin_name=  "Strata.name"){



  sample_frame <- sample_frame |> dplyr::rename(
    completed_survey = !!rlang::sym(completed_survey),
    pop_group = !!rlang::sym(pop_group),
    admin_name = !!rlang::sym(admin_name)
  )


  if(all(!sample_frame$pop_group %in% base_file$pop_group)){stop(
    unique(sample_frame$pop_group)[!unique(sample_frame$pop_group) %in% base_file$pop_group ] |>
      glue::glue_collapse(",") %>% glue::glue(., " was not found in the population group mentioned in the analysis file.")
  )
  }

  if(all(!sample_frame$admin_name %in% base_file$admin_name)){stop(
    unique(sample_frame$admin_name)[!unique(sample_frame$admin_name) %in% base_file$admin_name ] |>
      glue::glue_collapse(",") %>% glue::glue(., " was not found in the admin name mentioned in the analysis file.")
  )
  }


  base_info <- unique(base_file[c("pop_group", "admin_name","admin_level")])

  sample_frame |> dplyr::left_join(base_info) |>
    dplyr::ungroup() |> as.data.frame()


}
