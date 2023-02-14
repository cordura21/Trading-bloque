rets <- list()
library(readxl)
library(dplyr)
library(tidyr)
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

output_data <- bind_rows(rets)