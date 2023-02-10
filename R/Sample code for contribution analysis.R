xx <- port$stats$total_contribution
xx <- xx[,1:(NCOL(xx)-1)]
xx <- xx %>% xts_tbl()
xx <- xx %>% pivot_longer(-date)
ggplot(xx, aes(x=date,y=value, fill = name))+ 
  geom_area(alpha = 0.4) +
  stat_smooth() +
  facet_wrap(~name) +
 theme_bw() + theme(legend.position = 'none')
