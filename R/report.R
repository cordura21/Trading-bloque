if(vol_adjust == 1){
  
  name_case_to_run = paste0('VOL_ADJUSTED ',case_to_run)
  
}else{
  
  name_case_to_run  = case_to_run
  
}

report_path <- file.path('results',paste0(name_case_to_run,' backtest.html'))

rmarkdown::render('report.Rmd', output_file = report_path)
