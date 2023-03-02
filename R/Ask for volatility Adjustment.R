vol_choices <- c(TRUE,FALSE)

vol_adjust <- menu(TRUE,FALSE, title= "Adjust Volatility to first portfolio?")

if(vol_adjust > 1){
  # Adjust volatilities
  
  main_portfolio <- vol_choices[vol_adjust]
  
  
  
}
