Nicos_RDS_to_long_csv <- function()
{

library(dplyr)
x <- readRDS(file.choose()) %>% 
  tbl2xts::xts_tbl() %>%
  tidyr::pivot_longer(-date) %>%
   arrange(name,date,value) %>%
  select(date,name,value)

write.csv(x,'nicoRDS.csv')
}

