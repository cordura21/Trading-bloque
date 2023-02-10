# Read case data, prepare case assets ------------------------------------------

select_file <- file.choose() 
selected_case <- read_yaml(select_file)


case_to_run <- select_file %>% basename() %>% stringr::str_remove(".yml")

case_params <- selected_case[[1]]
portfolios <- selected_case[2:length(selected_case)]

# Create a list of all the assets in every portfolio on the case
case_assets <- character()

for(portfolio in portfolios){
  case_assets <- unique(c(case_assets,names(portfolio)))
}

case_returns <- funds[case_params$Period,case_assets] %>% na.omit()

iLoop <- 1 # Just for easier debugging