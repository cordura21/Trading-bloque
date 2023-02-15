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
  port$stats$total_contribution <- to.period.contributions(port$lists$portfolio_returns_verbose$contribution, period="all")
  current_contribution <- port$stats$total_contribution
  current_contribution <- current_contribution[,1:(NCOL(current_contribution)-1)]
  current_contribution <- current_contribution %>% xts_tbl()
  current_contribution <- current_contribution %>% pivot_longer(-date) %>%
    mutate(portfolio = names(portfolios)[iLoop])
  port$stats$total_contribution <- current_contribution
  
  # Add year by year contribution, used in a new chart.
  port$stats$total_contribution_yearly <- to.period.contributions(port$lists$portfolio_returns_verbose$contribution, period="years")
  current_contribution_yearly <- port$stats$total_contribution_yearly
  current_contribution_yearly <- current_contribution_yearly[,1:(NCOL(current_contribution_yearly)-1)]
  current_contribution_yearly <- current_contribution_yearly %>% xts_tbl()
  current_contribution_yearly <- current_contribution_yearly %>% pivot_longer(-date) %>%
    mutate(portfolio = names(portfolios)[iLoop])
  port$stats$total_contribution_yearly <- current_contribution_yearly
  
  port$data$cum_return <- cumprod(1+port$data$portfolio_returns)
  port$data$roll_return_12 <- TTR::ROC(x = port$data$cum_return,n = 12)
  port$data$roll_return_24 <- TTR::ROC(x = port$data$cum_return,n = 24)
  port$data$roll_return_36 <- TTR::ROC(x = port$data$cum_return,n = 36)
  #port$data$roll_return_60 <- TTR::ROC(x = port$data$cum_return,n = 60)
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
}

