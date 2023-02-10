report_path <- file.path('results',paste0(case_to_run,' backtest.html'))

rmarkdown::render('report.Rmd', output_file = report_path)
