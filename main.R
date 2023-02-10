source('R/calculate.R')
source('R/tables.R')
rmarkdown::render('report.Rmd', output_file = file.path('results',paste0(case_to_run,' backtest.html')))
                  