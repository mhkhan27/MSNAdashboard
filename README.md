
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MSNAdashboard

<!-- badges: start -->

[![contributions
welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Generic
badge](https://img.shields.io/badge/STATUS-UNDER%20DEVELOPMENT-%23007CE0)](https://shields.io/)

<!-- badges: end -->

The objective of MSNAdashboard is to offer a well-organized repository,
making it simpler and less time-consuming to design the dashboard.

## Step 1: Download the repository

You can download the repo from
[github](https://github.com/mhkhan27/MSNAdashboard)

## Step 2: What do you need?

<body>
<ul>
<li>
Clean dataset: It should be located in the directory
data-raw/cleaned_data and include two columns: one for the population
group information and another for stratification details.
</li>
<li>
Validated analysis: Must have key_index and stat column. It must be
validated from HQ. It needs to be placed within the directory
`data-raw/validated_analysis/`.
</li>
<li>
Kobo tool: It needs to be placed within the directory data-raw/.
</li>
<li>
Sample frame: It needs to be placed within the directory data-raw/.
</li>
<li>
Admin three level shape file: It needs to be placed within the directory
data-raw/admin_boundary/.
</li>
</ul>
</body>

#### 2.1 Admin boundary:

Please put the admin boundaries under data-raw/admin_boundary. You can
download the ocha adim boundaries by using following code.

``` r
admin_boundary <- MSNAdashboard::download_hdx_adm(country_code = "lbn",admin_level = 2,df_index = 2)  ## Downloading OCHA-COD admin 2 data for Lebanon
```

## Step 3. Create input file

### Step 3.1 Create and update dap

You can create the Data Analysis plan `write_dap_for_dashboard()`
function.

``` r
list_of_dataset <- list(
  HH_data = HH_data,
  INDV_data = INDV_data
)


write_dap_for_dashboard(list_of_dataset = list_of_dataset,
                        kobo_survey = survey,
                        column_name_for_populaion_group = "pop_group")
```

The out should look like-

``` r
openxlsx::read.xlsx("data-raw/DAP_for_dashboard.xlsx") |> head() 
#>        sector                                 indicator        main_variable
#> 1        <NA>                                      <NA>                today
#> 2 Demographic What is the name of the population group?            pop_group
#> 3        <NA>                                      <NA> data_collection_mode
#> 4        <NA>                                      <NA>          governorate
#> 5        <NA>                                      <NA>             district
#> 6        <NA>                                      <NA>     point_accessible
#>   analysis_level                                           label::English
#> 1        HH_data                                                    today
#> 2        HH_data                What is the name of the population group?
#> 3        HH_data Is this interview conducted in-person or over the phone?
#> 4        HH_data           In which governorate is the household located?
#> 5        HH_data              In which district is the household located?
#> 6        HH_data                                 Is the point accessible?
#>                                    label::Arabic
#> 1                                          اليوم
#> 2                          ما هي الفئة السكانية؟
#> 3 هل أجريت هذه المقابلة وجهاً لوجه أم عبر الهاتف؟
#> 4                       في أي محافظة تقع الأسرة؟
#> 5                         في أي قضاء تقع الأسرة؟
#> 6                  هل المنطقة يمكن الوصول إليها؟
```

Please choose the sector from the drop down menu and enter the indicator
label in the `indicator` column.

### Step 3.2 Check the validated analysis file

The function `check_validated_analysis()` will assess whether the
validated analysis contains any potential errors or not.

``` r
validated_analysis |> check_validated_analysis()
```

### Step 3.3 Fix admin mismatch

To join the map data with MSNA data, the strata name from the dataset
should be same as admin boundary name in the OCHA boundary. You can use
`write_mismatched_strata()` to compare the the admin names.

``` r
write_mismatched_strata(ocha_cod_level_3 = cntry_adm_3,
                        cod_admin1_name = "admin1Name",
                        cod_admin2_name = "admin2Name",
                        cod_admin3_name = "admin3Name",
                        validated_analysis = base_file,
                        admin_level_in_validated_analysis = "admin_level",
                        hh_data=df,
                        pop_group_in_validated_analysis = "pop_group" )
```

This will create a file called `admin_mismatch_fix.xlsx` under data-raw
folder. The file will have a list with mismatched admin names. The user
should fill the `ocha_cod_name` from the drop down menu.

#### STEP 3.4 Rename OCHA name

Once you fill the output file from `write_mismatched_strata` function
then we will need to apply the changes to either dataset or to OCHA
cod.However as MSNA data mostly contain multiple loop so its better to
rename the ocha boundaries. You can apply
`write_renamed_ocha_admin_name` so write the renamed OCHA boundary as
shapefile to use in the dashboard.

``` r
MSNAdashboard::write_renamed_ocha_admin_name(ocha_cod_level_3 = cntry_adm_3,
                              cod_admin1_name = "admin1Name",
                              cod_admin2_name = "admin2Name",
                              cod_admin3_name = "admin3Name",
                              mistached_list = mistached_list,
                              output_path = "data-raw/admin_boundary/OCHA_renamed_adm3.shp")
```

The function will create a shapefile under data-raw folder named
`OCHA_renamed_adm3`. At this stage you can dissolve the admin3 to
admin2,admin1,and admin0 by following code:

``` r
OCHA_renamed_adm3 <- sf::st_read( "data-raw/admin_boundary/OCHA_renamed_adm3.shp")

## admin 2
OCHA_renamed_adm2 <- OCHA_renamed_adm3 |> dplyr::group_by(admin0Name,admin1Name,admin2Name) |> dplyr::summarise() 
|> rmapshaper::ms_simplify()

sf::st_write(OCHA_renamed_adm2,"data-raw/admin_boundary/OCHA_renamed_adm2.shp")


## admin 1
OCHA_renamed_adm1 <- OCHA_renamed_adm2 |> dplyr::group_by(admin0Name,admin1Name) |> dplyr::summarise() 
|> rmapshaper::ms_simplify()

sf::st_write(OCHA_renamed_adm1,"data-raw/admin_boundary/OCHA_renamed_adm1.shp")

## admin 0
OCHA_renamed_adm0 <- OCHA_renamed_adm1 |> dplyr::group_by(admin0Name) |> dplyr::summarise() 
|> rmapshaper::ms_simplify()

sf::st_write(OCHA_renamed_adm0,"data-raw/admin_boundary/OCHA_renamed_adm0.shp")
```

### Step 3.5 : Prepare text input file

`create_text_input()` is a function that generates an Excel file, which
should be completed with detailed information such as an overview,
methodology, limitations, and contact person details. Additionally,
please note that the function requires an improved version and a
comprehensive README for proper usage and understanding.

## Step 4: Export data as rda format/prepare data for dashboard

After filling and updating all the files under the `data-raw/`
directory, the subsequent step involves checking and preparing the file
to be used for the dashboard. Before running `app.R`, it is essential to
execute `data_preparation.R`. Both scripts contain comments, so their
functionalities are adequately explained within the code.

## 5 How to customize the dashboard?

In case you want to customize the dashboard, you can follow the
following steps -

### Step 5.1.1 Clone the repo

To customized the dashboard, you first need to clone the repository from
the [github](https://github.com/mhkhan27/MSNAdashboard).

#### Step 5.1.2 Understanding the repo

Once you are done with the repo, now you need to understand the
structure of repo. The repository is created using `golem` package.

##### 5.1.2.1 What is golem?

The `golem` package is a framework for building and deploying
production-ready Shiny applications in R. Shiny is a web application
framework for R that allows users to create interactive web applications
using R code. However, while Shiny is great for creating interactive
prototypes, it is not always well-suited for building production-ready
applications with robust performance, security, and scalability.

This is where`golem` comes in. `Golem` provides a framework for
organizing and structuring your Shiny code to create scalable and
maintainable applications. It includes a set of best practices and
conventions for building Shiny applications, such as separating the UI
(user interface) and server logic into separate files, using reactive
programming to minimize data processing, and leveraging package
management to simplify dependency management.

In addition to these best practices, `golem` also provides a set of
tools for testing, debugging, and deploying Shiny applications. For
example, it includes a command-line interface for creating and managing
application templates, as well as tools for managing application
configuration, logging, and error handling.

Overall, the `golem` package is a powerful tool for building robust,
scalable, and maintainable Shiny applications in R.

##### 5.1.2.2 Repository Stucture

The Golem package in R is designed to facilitate the creation of
production-ready Shiny applications. It is organized into several
subdirectories, each of which serves a specific purpose:

1.  `R/:` This directory contains the R code for your application. You
    should place your application logic, including any functions you
    write, in this directory.

2.  `data/:` This directory is used to store any data files that your
    application needs to function. You can also store any other
    resources that your application requires in this directory.

3.  `www/:` This directory is used to store any static files that your
    application requires, such as images, stylesheets, or JavaScript
    files.

4.  `inst/:` This directory is used to store any additional files that
    your application needs to function, such as configuration files or
    documentation.

5.  `tests/:` This directory is used to store any test files for your
    application. You can write unit tests for your application logic in
    this directory.

6.  `man/:` This directory contains the documentation for your
    application. You should document your functions and other objects in
    this directory using the Roxygen2 syntax.

7.  `NAMESPACE:` This file specifies the package’s exported functions
    and other objects.

8.  `DESCRIPTION:` This file contains metadata about your package,
    including its name, version, and dependencies.

9.  `README.md:` This file contains information about your package,
    including how to install and use it

<!-- -->

    #> .
    #> ├── R
    #> │   ├── app_config.R
    #> │   ├── app_server.R
    #> │   ├── app_ui.R
    #> │   ├── run_app.R
    #> │   ├── golem_utils_server.R
    #> │   ├── golem_utils_ui.R
    #> │   ├── mod_Graph.R
    #> │   ├── mod_introduction.R
    #> │   ├── mod_map.R
    #> │   ├── global.R
    #> │   ├── creating_base_file.R
    #> │   ├── create_sample_frame.R
    #> │   ├── utils-pipe.R
    #> │   ├── create_overview_map.R
    #> │   ├── download_hdx_admin.R
    #> │   ├── create_dap_for_dashboard.R
    #> │   ├── identifying_mismatch_strata_name_with_ocha_cod.R
    #> │   ├── check_validated_analysis.R
    #> │   ├── rename_cod.R
    #> │   └── create_text_file.R
    #> ├── MSNAdashboard.Rproj
    #> ├── dev
    #> │   ├── 01_start.R
    #> │   ├── 02_dev.R
    #> │   ├── 03_deploy.R
    #> │   └── run_dev.R
    #> ├── inst
    #> │   ├── app
    #> │   │   └── www
    #> │   │       ├── favicon.ico
    #> │   │       └── reach_logo.png
    #> │   └── golem-config.yml
    #> ├── man
    #> │   ├── creating_base_file.Rd
    #> │   ├── create_dashboard.Rd
    #> │   ├── create_overview_map.Rd
    #> │   ├── create_sample_frame_file.Rd
    #> │   ├── pipe.Rd
    #> │   └── figures
    #> │       └── README-pressure-1.png
    #> ├── DESCRIPTION
    #> ├── NAMESPACE
    #> ├── tests
    #> │   ├── testthat
    #> │   │   ├── test-golem_utils_server.R
    #> │   │   └── test-golem_utils_ui.R
    #> │   └── testthat.R
    #> ├── data-raw
    #> │   ├── admin_boundary
    #> │   │   ├── OCHA_renamed_adm0.dbf
    #> │   │   ├── OCHA_renamed_adm0.prj
    #> │   │   ├── OCHA_renamed_adm0.shp
    #> │   │   ├── OCHA_renamed_adm0.shx
    #> │   │   ├── OCHA_renamed_adm1.dbf
    #> │   │   ├── OCHA_renamed_adm1.prj
    #> │   │   ├── OCHA_renamed_adm1.shp
    #> │   │   ├── OCHA_renamed_adm1.shx
    #> │   │   ├── OCHA_renamed_adm2.dbf
    #> │   │   ├── OCHA_renamed_adm2.prj
    #> │   │   ├── OCHA_renamed_adm2.shp
    #> │   │   ├── OCHA_renamed_adm2.shx
    #> │   │   ├── OCHA_renamed_adm3.dbf
    #> │   │   ├── OCHA_renamed_adm3.prj
    #> │   │   ├── OCHA_renamed_adm3.shp
    #> │   │   └── OCHA_renamed_adm3.shx
    #> │   ├── validated_analysis
    #> │   │   └── Validated_analysis.csv
    #> │   ├── cleaned_data
    #> │   │   └── cleaned_data.xlsx
    #> │   ├── text_file.xlsx
    #> │   ├── kobo_tool.xlsx
    #> │   ├── sample_frame.csv
    #> │   ├── DAP_for_dashboard.xlsx
    #> │   └── admin_mismatch_fix.xlsx
    #> ├── style.css
    #> ├── app.R
    #> ├── data
    #> │   ├── base_file.rda
    #> │   ├── text_file.rda
    #> │   ├── overview.rda
    #> │   ├── methodology.rda
    #> │   ├── limitation.rda
    #> │   ├── contact_name.rda
    #> │   ├── contact.rda
    #> │   ├── admin_three_sf.rda
    #> │   ├── admin_two_sf.rda
    #> │   ├── admin_one_sf.rda
    #> │   ├── admin_zero_sf.rda
    #> │   ├── sample_frame_for_dashboard.rda
    #> │   └── overview_map.rda
    #> ├── LICENSE
    #> ├── LICENSE.md
    #> ├── data_preparation.R
    #> ├── README.Rmd
    #> └── README.md

##### 5.1.2.3 Understanding Module

With in the `R/` folder you will scripts started with `mod_` which I
will be calling module. Each module represent a `tab` in the dashboard.
Within the scripts, each module have two parts, 1. user interface (ui)
2. server.

##### Step 5.1.2.4 Removing any module

If you want to remove any module/tab from the dashboard, you can easily
do it from `app_ui.R` and `app_server.R`. All you have to do is delete
the module from both `app_ui` and `app_server`

##### Step 5.1.2.5 Adding any module

If you want to add a new tab then you will need to create a module first
and then add the module to the `app_ui.R` and `app_server.R`

``` r
## to create the module
golem::add_module(name = "name_of_module1", with_test = TRUE) # Name of the module
```

##### Step 5.1.2.6 Changing any module

You can change a specific tab without creating error in out tab by
editing existing module. just make the changes in `mod_name_of_module1`
and then you are all set. \[Make sure you have made changes in both ui
and server\]

## Step 5.2 Check the tests

If you made any changes in the dashboard, please make sure you have run
the tests before deploying the app. It will make sure the the changes
didn’t change anything in other tab or in the app. You can hit
`Ctrl + Shift + T` to run the tests

#### Step 5.3 CMD check

It is also important to run the CDM check. If your CDM check fails then
the app may runs in local but in the shinyserver it might not run. You
can hit `Ctrl + Shift + E` to run the CMD checks

#### Step 5.4 Run the app again

``` r
MSNAdashboard::create_dashboard(country = "Iraq",
                               assessment_name  = "McNA",
                               year = 2024
                               ) 
```
