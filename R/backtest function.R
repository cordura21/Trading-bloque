library(tbl2xts)
library(tidyr)
case_stats <- function(portfolios){
  joined_stats <- list()
  for(i in 1:length(portfolios)){
    joined_stats[[i]] <- portfolios[[i]][['table']]
  }
  return(bind_rows(joined_stats))
}

portfolio_data <- function(portfolios, data.name = 'portfolio_returns'){
  joined_stats <- xts()
  for(i in 1:length(portfolios)){
    joined_stats <- merge(joined_stats,portfolios[[i]][["data"]][[data.name]])
    
  }
  joined_stats <- tbl2xts::xts_tbl(joined_stats)
  joined_stats <- tidyr::pivot_longer(joined_stats, -date) %>%
    arrange(name,date) %>% mutate(variable = data.name)
  return((joined_stats))
}

portfolio_data_xts <- function(portfolios, data.name = 'portfolio_returns'){
  joined_stats <- xts()
  for(i in 1:length(portfolios)){
    joined_stats <- merge(joined_stats,portfolios[[i]][["data"]][[data.name]])
  }
  
  return((joined_stats))
}

data_rolling_performance <- function (R, width = 12, FUN = "Return.annualized", ..., ylim = NULL, main = NULL, fill = NA){
  x = checkData(R)
  columns = ncol(x)
  columnnames = colnames(x)
  dotargs <- list(...)
  funargsmatch = pmatch(names(dotargs), names(formals(FUN)), 
                        nomatch = 0L)
  funargs = dotargs[funargsmatch > 0L]
  if (is.null(funargs)) 
    funargs = list()
  funargs$... = NULL
  plotargs = dotargs[funargsmatch == 0L]
  plotargs$... = NULL
  if (!length(plotargs)) 
    plotargs = list()
  funargs$width = width
  funargs$FUN = FUN
  funargs$fill = fill
  funargs$align = "right"
  for (column in 1:columns) {
    rollargs <- c(list(data = na.omit(x[, column, drop = FALSE])), 
                  funargs)
    column.Return.calc <- do.call(rollapply, rollargs)
    if (column == 1) 
      Return.calc = xts(column.Return.calc)
    else Return.calc = merge(Return.calc, column.Return.calc)
  }
  if (is.null(ylim)) {
    ylim = c(min(0, min(Return.calc, na.rm = TRUE)), max(Return.calc, 
                                                         na.rm = TRUE))
  }
  colnames(Return.calc) = columnnames
  if (is.null(main)) {
    freq = periodicity(R)
    switch(freq$scale, minute = {
      freq.lab = "minute"
    }, hourly = {
      freq.lab = "hour"
    }, daily = {
      freq.lab = "day"
    }, weekly = {
      freq.lab = "week"
    }, monthly = {
      freq.lab = "month"
    }, quarterly = {
      freq.lab = "quarter"
    }, yearly = {
      freq.lab = "year"
    })
    main = paste(columnnames[1], " Rolling ", width, 
                 "-", freq.lab, " ", FUN, sep = "")
  }
  plotargs$main = main
  plotargs$ylim = ylim
  if (hasArg("add")) {
    plotargs$x = Return.calc
    plotargs$add = NULL
    suppressWarnings(do.call(addSeries, plotargs))
  }
  else {
    plotargs$R = Return.calc
    suppressWarnings(do.call(chart.TimeSeries, plotargs))
  }
  
  return(Return.calc)
}


