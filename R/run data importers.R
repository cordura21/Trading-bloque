# Load libraries ----------------------------------------------------------
rets <- list()
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)

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


# Join all inputs and save ------------------------------------------------
output_data <- bind_rows(rets)
write.csv(output_data,'data importers/returns.csv', row.names = FALSE)