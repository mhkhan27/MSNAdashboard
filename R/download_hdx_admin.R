
#' Function to download HDX admin boundary
#'
#' @param country_code ISO country code.
#' @param admin_level admin level (0-3). Must be numeric. Default is 3.
#' @param df_index HDX index number from the printed table. The function should take the index number automatically but some cases (i.e Multiple shapefile), manual entry needed.
#' @param keep_zip To keep downloaded shape files (All level of admin boundary will be available under data-raw/OCHA_shapefile folder). Default is FALSE, means, it will delete the folder.
#' @param output_path Path where you want to keep the shape files for admin levels
#' @return OCHA common operational data set for specified level as an sf object.
#' @export
#'



download_hdx_adm <- function(country_code,admin_level=3,df_index=NULL,keep_zip =F,output_path = "data-raw" ){

  options(timeout=1000) ## setting download timeout to 1000s

  output_path <- paste0(output_path,"/ocha_cod_raw")

  if(!admin_level %in% c(0:3)){stop("admin_level must be a integer number and it should be in between 0 and 4")}

  # CREATE AND DELETE (IF EXISTS) TEMP DIRECTORY
  if(file.exists(output_path)){unlink(output_path,recursive = TRUE)}
  temp_folder <- dir.create(output_path)

  resource_name_only <- rhdx::search_datasets(paste0("cod-ab-",country_code),rows = 1) |> purrr::pluck(1)
  res_df<-resource_name_only$data$resources |> as.data.frame()

  name_df <- res_df |> dplyr::select(starts_with("name"))


  index_df_index <- name_df|> tidyr::pivot_longer(names(name_df),names_to ="cols",values_to = "name_of_resource") |>
    dplyr::mutate(
      index = dplyr::cur_group_rows()
    )


  index_df_filtered <- index_df_index|> dplyr::filter(grepl("_shp|_SHP|Shapefiles",name_of_resource))

  if(is.null(df_index) & nrow(index_df_filtered) == 1){
    index =index_df_filtered$index
  }
  if(!is.null(df_index)){index =df_index}

  print(index_df_index)

  if(nrow(index_df_filtered) != 1 & is.null(df_index)) {
    index <-  as.integer(readline(prompt= "Multiple/no index number found.Please specify the dataset index number from above table- "))
  }
  print(paste0("Index number ",index, " used."))

  resource_name <- resource_name_only |>
    rhdx::get_resource(index)

  layer_name <- resource_name |> rhdx::download_resource(folder = paste0(output_path,"/"))

  list_all_shp <- unzip(zipfile = layer_name, list = TRUE)

  adm_lvl <- paste0("adm",admin_level)


  admin_shape_file <- list_all_shp$Name[grepl(adm_lvl,list_all_shp$Name)]

  admin_shape_fileshp <- admin_shape_file[grepl("shp",admin_shape_file)]
  admin_shape_fileshp2 <- admin_shape_fileshp[grepl(".shp.xml",admin_shape_fileshp)]

  final_shape_name <- admin_shape_fileshp [!admin_shape_fileshp %in% admin_shape_fileshp2]

  utils::unzip(layer_name, exdir = paste0(output_path,"/"))

  adm <- sf::st_read(paste0(output_path,"/",final_shape_name))

  if(keep_zip == F){unlink(output_path,recursive = TRUE)}

  return(adm)
}
