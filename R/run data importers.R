# Load libraries ----------------------------------------------------------
rets <- list()
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# Winton Multi Strategy Import
winton <- read.csv('data importers/Winton import/tabula-winton returns.csv')
names(winton)[2:13] <- 1:12
winton <- winton[1:13]
winton <- winton %>% pivot_longer(-year) %>%
  mutate(date = Sys.Date()
         , value = value / 100
         , source = 'winton presentation')
year(winton$date) <- as.numeric(winton$year )
month(winton$date) <- as.numeric(winton$name )
day(winton$date) <- 1
winton$name <- "Winton Multi Strategy"
winton <- winton %>% select(date,name,value,source)
write.csv(winton,file = 'data importers/bloomberg csv/Winton Multi Strategy.csv',row.names = FALSE)

# Lynx Program Import -----------------------------------------------------

lynx_data <- read_excel('data importers/lynx import/data from lynx website.xlsx',sheet = 'Sheet1')[,1:13]


lynx_data <- lynx_data %>%
  pivot_longer(!year) %>% na.omit() %>%
  mutate(date = Sys.Date())
year(lynx_data$date) <- lynx_data$year  
month(lynx_data$date) <- as.numeric(lynx_data$name )
day(lynx_data$date) <- 1

lynx_data <- lynx_data %>%
  mutate(name = 'The Lynx Program'
         , source = "lynxhedge.se") %>%
  select(date,name,value, source)

write.csv(lynx_data,file = 'data importers/bloomberg csv/The_Lynx_fund.csv',row.names = FALSE)


# AQR Imports -------------------------------------------------------------
rets$AQR_factors <- read_excel('data importers/aqr factors/Century of Factor Premia Monthly.xlsx', sheet = 'Century of Factor Premia', skip = 18) 
names(rets$AQR_factors)[1] <- 'date'
rets$AQR_factors$date <- as.Date(rets$AQR_factors$date)
rets$AQR_factors <- pivot_longer(rets$AQR_factors,!date)
rets$AQR_factors$source <- 'aqr factors'

rets$AQR_TSM <- read_excel('data importers/aqr time series momentum/Time Series Momentum Factors Monthly.xlsx', sheet = 'TSMOM Factors', skip = 17)
names(rets$AQR_TSM)[1] <- 'date'
rets$AQR_TSM$date <- as.Date(rets$AQR_TSM$date)
rets$AQR_TSM <- pivot_longer(rets$AQR_TSM,!date)
rets$AQR_TSM$source <- 'aqr time series momentum'


# IASG import -------------------------------------------------------------
iasg_files <- list.files('data importers/iasg/',pattern = '*.csv')
iasg_data <- data.frame()

for(file in iasg_files){
  print(file)
  curr_file <- iasg_files[file]
  curr_file_contents <- read.csv(file.path('data importers/iasg/',file))
  names(curr_file_contents)[1] <- 'Year' ## Levantaba el .csv con este nombre la columna de year "ï..Year"
  curr_file_contents$name <- file
  iasg_data <- rbind(iasg_data,curr_file_contents)
}

iasg_data$date <- Sys.Date()
year(iasg_data$date) <- iasg_data$Year
month(iasg_data$date) <- iasg_data$Month
day(iasg_data$date) <- 1
iasg_data$value <- iasg_data$Return / 100
iasg_data <- iasg_data %>% select(date,name,value)
iasg_data$source <- 'iasg csv files'
rets$iasg <- iasg_data 

# CSV BBG import -------------------------------------------------------------
csv_files <- list.files('data importers/bloomberg csv/',pattern = '*.csv')
csv_data <- data.frame()

for(file in csv_files){
  print(file)
  curr_file <- csv_files[file]
  curr_file_contents <- read.csv(file.path('data importers/bloomberg csv/',file))
  csv_data <- rbind(csv_data,curr_file_contents)
}

rets$csv_data <- csv_data %>% as_tibble() %>% 
  mutate(date = as.Date(date),name = as.character(name),source = as.character(source))

# Join all inputs and save ------------------------------------------------
output_data <- bind_rows(rets) %>% na.omit()
write.csv(output_data,'data importers/returns.csv', row.names = FALSE)

output_data_stats <- output_data %>% arrange(source,name,date) %>%
  group_by(source,name) %>%
  summarise(first_date = dplyr::first(date), last_date = dplyr::last(date)
            , observations = n(), min = min(value), max = max(value)
            , nas = sum(is.na (value)))

output_data_stats_sources <- output_data %>% arrange(source,name,date) %>%
  group_by(source) %>%
  summarise(first_date = dplyr::first(date), last_date = dplyr::last(date)
            , observations = n(), min = min(value), max = max(value)
            , nas = sum(is.na (value)))

report_path <- file.path('data importers/',paste0('importer_report.html'))

rmarkdown::render('importer report.Rmd', output_file = report_path)

