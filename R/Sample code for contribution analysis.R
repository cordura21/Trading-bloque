current_contribution <- port$stats$total_contribution
current_contribution <- current_contribution[,1:(NCOL(current_contribution)-1)]
current_contribution <- current_contribution %>% xts_tbl()
current_contribution <- current_contribution %>% pivot_longer(-date) %>%
  mutate(portfolio = names(portfolios)[iLoop])

ggplot(current_contribution, aes(x=date,y=value, fill = name))+ 
  geom_area(alpha = 0.4) +
  stat_smooth() +
  facet_wrap(~name) +
 theme_bw() + theme(legend.position = 'none')
