# Libraries and sources ---------------------------------------------------
library(readxl)
library(tidyr)
library(PerformanceAnalytics)
library(yaml)
library(pander)
library(dplyr)
library(tidyr)
library(ggplot2)
library(reactable)
library(data.table)
library(lubridate)
library(stringr)
library(TSclust)

source('R/backtest function.R')

# Read data and params ---------------------------------------------------------

params <- read_yaml('portafolios.yml')
funds <- read_excel(path = "data/returns.xlsx", sheet = 'returns')

#force dates to end of month dates. This is useful if you have for example
# 1970-12-01 and 1970-12-31 in the same file, because you joined files with
# multiple monthly formats.

if(params$global.settings$force.end.of.months == TRUE){
  funds$date <- lubridate::ceiling_date(funds$date, "month") - 1
}

funds <- funds %>% pivot_wider(names_from = ticker, values_from = rets) %>%
  mutate(date = as.Date(date))
funds$Uninvested <- 0
names(funds)[1] <- 'date'

funds <- xts(funds[,-1],funds$date)
