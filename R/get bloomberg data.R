## Get Bloomberg Data ##

## Libraries
library(Rbbg)
library(yaml)
library(dplyr)

## Get YAML  params
bbg.params <- read_yaml('data importers//bloomberg csv//bbg_tickers.yml')

## Connect to bloomberg data
conn <- blpConnect(throw.ticker.errors = FALSE)

## Loop to get returns of tickers 
for(iLoop in 1:length(bbg.params)){

  temp.params <- bbg.params[[iLoop]]
  temp.csvname <- temp.params$csv.name
  
  ## Check if the file already exists (do not get data for this ticker if we already have data)
  if(paste0(temp.csvname,'.csv') %in% list.files('data importers//bloomberg csv//')){
    next()
  }
  
  ## Params of the current asset
  temp.ticker <- temp.params$ticker
  temp.field <- temp.params$field
  temp.startdate <- temp.params$start.date
  temp.enddate <- temp.params$end.date
  temp.periodicity <- temp.params$periodicity
  temp.currency <- temp.params$currency
  
  ## Bring bloomberg prices
  temp.results <- bdh(conn, temp.ticker,temp.field,temp.startdate,temp.enddate,
                      option_names = c("periodicitySelection","currency"), 
                      option_values = c(temp.periodicity,temp.currency),
                      dates.as.row.names=FALSE,always.display.tickers = TRUE,
                      include.non.trading.days = FALSE)
  
  ## Tidy data and calculate returns
  bbg.results <- temp.results %>% 
    mutate(date = as.Date(date),
           name = temp.csvname,
           value = TTR::ROC(PX_LAST,type = 'discrete'),
           source = 'Bloomberg') %>% 
    select(date,name,value,source) %>% na.omit() 
  
  print(temp.csvname)
  
  ## Write csv
  write.csv(bbg.results,paste0('data importers//bloomberg csv//',temp.csvname,'.csv'),row.names = FALSE)
  
}
