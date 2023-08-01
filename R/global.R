
# plotly_titel ------------------------------------------------------------

title_style <- list(
  family = "Roboto Condensed",
  size = 20,
  color = "#333333")

#
# base_file$admin_level <- base_file$admin_level |> factor(levels = c("National","Governorate","District") )

# # Assessed and non assessed map  ------------------------------------------
#
#
# ### Overview_map , The following part must be updated.
#














#   label <- assessed_not_assesd[[i]] |> dplyr::filter(!is.na(completed_survey)) |> dplyr::pull(admin_label)  |> unique()

# ### Getting Strata + population
# look_for_strata<-list()
# for(i in strata_checking$pop_group){
# strata <- strata_checking |> dplyr::filter(pop_group == i)  |> dplyr::pull(strata)
#
# key <- paste0(i, " ~ " , unique(HH_data[[strata]]))
#
# if(all(key %in% validated_analysis$group_var_value)) {key <- key}
# if(all(!key %in% validated_analysis$group_var_value)) {key <-  paste0(unique(HH_data[[strata]]), " ~ " , i)}
#
#
# look_for_strata[[i]]<- data.frame(
#    group_var_value = key,
#    pop_group = i,
#    strata = strata,
#    # group_val_value_1 = i,
#    admin_name = unique(HH_data[[strata]])
#  )
#
# }
# # do.call("bind_rows",look_for_strata)
# look_for_strata_df <-  dplyr::bind_rows(look_for_strata) |> as.data.frame()
#
#
# ######## Strata level data for MAP
#
# validated_analysis_strata <- validated_analysis |> dplyr::filter(group_var_value %in% look_for_strata_df$group_var_value)
#
# validated_analysis_strata <- validated_analysis_strata |> dplyr::left_join(look_for_strata_df)
#
# validated_analysis_strata |> names()
#
# validated_analysis_strata <- validated_analysis_strata |>  dplyr::left_join(strata_checking,by = c("pop_group","strata"))
#
# # validated_analysis_strata can be use in map tab, picker input for population group and indicator + choice and then leftjoing with
# # admin boundy ( based on admin_level column), finally show the result
#
#
#
