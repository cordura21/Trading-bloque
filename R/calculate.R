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


# Read case data, prepare case assets ------------------------------------------


case_to_run <- params$RunThisCase
case_params <- params[[case_to_run]][[1]]
portfolios<- params[[case_to_run]][2:length(params[[case_to_run]])]

# Create a list of all the assets in every portfolio on the case
case_assets <- character()

for(portfolio in portfolios){
  case_assets <- unique(c(case_assets,names(portfolio)))
}

case_returns <- funds[case_params$Period,case_assets] %>% na.omit()

iLoop <- 1 # Just for easier debugging





# Do portfolios calculations ----------------------------------------------

for(iLoop  in 1:length(portfolios)) {
  port <- portfolios[[iLoop]]
  
  asset_returns <- case_returns[,names(port)] %>% na.omit()
  asset_weights <- as.numeric(unlist(port))
  
  # add new calculations and data to the original portfolios object
  
  port$data <- list()
  port$stats <- list()
  port$lists <- list()
  port$table <- list()
  
  port$data$component_returns <- asset_returns
  port$stats$weights <- asset_weights  
  
  # calculate full portfolio stats 
  port$lists$portfolio_returns_verbose <- Return.portfolio(R = asset_returns
                                                           , rebalance_on = case_params$Rebalance
                                                           , weights = asset_weights
                                                           , verbose = TRUE)
  
  # add portfolio returns vector to the portfolio data
  port$data$portfolio_returns <- port$lists$portfolio_returns_verbose$returns
  names(port$data$portfolio_returns) <- names(portfolios)[iLoop]
  
  port$data$drawdown <- Drawdowns(port$data$portfolio_returns)
  port$data$running_volatility <- TTR::runSD(port$data$portfolio_returns,n = 36) * sqrt(12)
  names(port$data$running_volatility) <- names(portfolios)[iLoop]  
  # Add portfolio contribution by asset to the stats
  port$stats$total_contribution <- to.period.contributions(port$lists$portfolio_returns_verbose$contribution
                                                           , period="all")
  
  port$data$cum_return <- cumprod(1+port$data$portfolio_returns)
  port$data$roll_return_12 <- TTR::ROC(x = port$data$cum_return,n = 12)
  port$data$roll_return_24 <- TTR::ROC(x = port$data$cum_return,n = 24)
  port$data$roll_return_36 <- TTR::ROC(x = port$data$cum_return,n = 36)
  port$data$roll_return_60 <- TTR::ROC(x = port$data$cum_return,n = 60)
  port$data$Rolling_sharpe_36  <- data_rolling_performance(port$data$portfolio_returns,width = 36, FUN = 'SharpeRatio.annualized')
  
  # Add some stats
  
  port$table$Growth <- Return.cumulative(port$data$portfolio_returns)
  port$table$CAGR <- Return.annualized(port$data$portfolio_returns)
  port$table$Vol <- sd.annualized(port$data$portfolio_returns)
  port$table$maxDD <- table.Drawdowns(port$data$portfolio_returns)[1,'Depth']
  port$table$maxDDLength <- table.Drawdowns(port$data$portfolio_returns)[1,'Length']
  port$table$Sharpe <- SharpeRatio.annualized(port$data$portfolio_returns)
  port$table$Calmar <- CalmarRatio(port$data$portfolio_returns) 
  
  
  port$table <- bind_cols(port$table) %>% t() %>% as.data.frame()
  port$table$portfolio <- names(portfolios[iLoop])
  names(port$table)[1] <- 'value'
  port$table$variable <- row.names(port$table)
  row.names(port$table) <- NULL
  
  portfolios[[iLoop]] <- port 

tables <- list()
tables$summary_stats <- pivot_wider(case_stats(portfolios),names_from = variable)
reactable::reactable(tables$summary_stats
                     ,outlined = FALSE,highlight = TRUE
                     ,columns = list(
                       portfolio = colDef(minWidth = 120)
                       ,Growth = colDef(format = colFormat(percent = TRUE,digits = 0,locales = "en-US"))
                       ,CAGR = colDef(format = colFormat(percent = TRUE, digits = 2,locales = "en-US"))
                       ,maxDD = colDef(format = colFormat(percent = TRUE, digits = 1,locales = "en-US"))
                       ,Vol = colDef(format = colFormat(percent = TRUE, digits = 1,locales = "en-US"))
                       , Sharpe = colDef(format = colFormat(digits = 1,locales = "en-US"))
                       , Calmar = colDef(format = colFormat(digits = 1,locales = "en-US"))))

}