vol_choices <- c("No adjustment", names(portfolio))

vol_adjust <- menu(vol_choices, title= "Adjust volatilities to:")

if(vol_adjust == 1){
  # Adjust volatilities
}
