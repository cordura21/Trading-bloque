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

source('R/backtest function.R')


# Read data and params ---------------------------------------------------------
params <- read_yaml('portafolios.yml')

funds <- read_excel(path = "data/returns.xlsx", sheet = 'returns')