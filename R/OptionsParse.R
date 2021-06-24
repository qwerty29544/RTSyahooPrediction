library(jsonlite)
options_list <- jsonlite::fromJSON(txt = "options/options.json")
symbols_list <- jsonlite::fromJSON(txt = "options/symbols.json")
cran_settings <- jsonlite::fromJSON(txt = "options/CRANsettings.json")
