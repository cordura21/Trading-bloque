tables <- list()
tables$summary_stats <- pivot_wider(case_stats(portfolios),names_from = variable)

investable_assets <- case_returns[,!(names(case_returns) %in% "Uninvested")]

if(NCOL(investable_assets) > 1){
  stocks = t(as.matrix(investable_assets))
  D1 <- diss(stocks, "COR")
  C1 <- hclust(D1)  
}

contribution_table <- list()
for(i in 1:length(portfolios)){
  contribution_table[[i]] <- portfolios[[i]]$stats$total_contribution
}

contribution_table <- bind_rows(contribution_table) %>%
  arrange(portfolio) %>% group_by(portfolio) %>%
  arrange(desc(value)) 


contribution_table_yearly <- list()
for(i in 1:length(portfolios)){
  contribution_table_yearly[[i]] <- portfolios[[i]]$stats$total_contribution_yearly
}

contribution_table_yearly <- bind_rows(contribution_table_yearly) %>%
  arrange(portfolio) %>% group_by(portfolio) %>%
  arrange(desc(value)) 


