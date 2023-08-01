
#' Check validated analysis file
#'
#' @param validated_analysis
#'
#' @return error/warning messeges.
#' @export
#'

check_validated_analysis <- function(validated_analysis){

  ### Need to check key_index column format once the function available in the analysistools package


   # name check
  required_col <- c( "key_index", "stat", "admin_name", "admin_level", "pop_group")


  if(any(!required_col %in% names(validated_analysis))){ stop(
    required_col[!required_col %in% names(validated_analysis)] |> glue::glue_collapse(", ") %>%
      glue::glue(., " was not found in the validated analysis. The column name should match exactly"))
  }


  # admin_level

  admin_level_check <- validated_analysis$admin_level |> unique()
  required_admin_level <- c("admin0","admin1","admin2","admin3","admin4")
  if(any(!admin_level_check %in% required_admin_level)){ stop(
    admin_level_check[!admin_level_check %in% required_admin_level] |> glue::glue_collapse(", ") %>%
      glue::glue(., " is not a valid input. The admin_level must be either - admin0 or admin1 or admin2 or admin3 or admin4"))
  }

  # admin name - should not contain admin0 ... admin1
#
  admin_name_check <- validated_analysis$admin_name |> unique()
  not_required_admin_name <- c("admin0","admin1","admin2","admin3","admin4")

  if(any(admin_name_check %in% not_required_admin_name)){warning(
    admin_name_check[admin_name_check %in% not_required_admin_name] |> glue::glue_collapse(", ") %>%
      glue::glue(., " might not a valid input. Seems like its admin level info instead of admin name"))
  }

  return(validated_analysis)
}


#####################3

# x |> check_validated_analysis()
