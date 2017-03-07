.helper_func.env = new.env()

assign("tex2rmd_patterns", "data/tex2rmd_patterns.csv", envir = .helper_func.env)
assign("tex2rmd_theorems", "data/tex2rmd_theorems.csv", envir = .helper_func.env)
sys.source("R/convert.R", envir = .helper_func.env)
sys.source("R/journaling.R", envir = .helper_func.env)
sys.source("R/bookdown.R", envir = .helper_func.env)

attach(.helper_func.env)
