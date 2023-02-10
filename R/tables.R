tables <- list()
tables$summary_stats <- pivot_wider(case_stats(portfolios),names_from = variable)
summary_table <- reactable::reactable(tables$summary_stats
                     ,outlined = FALSE,highlight = TRUE
                     ,columns = list(
                       portfolio = colDef(minWidth = 120)
                       ,Growth = colDef(format = colFormat(percent = TRUE,digits = 0,locales = "en-US"))
                       ,CAGR = colDef(format = colFormat(percent = TRUE, digits = 2,locales = "en-US"))
                       ,maxDD = colDef(format = colFormat(percent = TRUE, digits = 1,locales = "en-US"))
                       ,Vol = colDef(format = colFormat(percent = TRUE, digits = 1,locales = "en-US"))
                       , Sharpe = colDef(format = colFormat(digits = 1,locales = "en-US"))
                       , Calmar = colDef(format = colFormat(digits = 1,locales = "en-US"))))


investable_assets <- case_returns[,!(names(case_returns) %in% "Uninvested")]

if(NCOL(investable_assets) > 1){
  stocks = t(as.matrix(investable_assets))
  D1 <- diss(stocks, "COR")
  C1 <- hclust(D1)  
}

