
## Add to table object the other tables
tables$contribution_table <- contribution_table
tables$contribution_table_yearly <- contribution_table_yearly

## Add tables objetct into portfolios object
portfolios$tables <- tables

## Save RDS
saveRDS(portfolios,paste0('data results//',case_to_run,'.RDS'))
