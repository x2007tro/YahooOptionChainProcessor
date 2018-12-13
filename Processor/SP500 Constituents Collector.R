lib <- c("lubridate", "htmltab", "dplyr")
lapply(lib, function(x){library(x, character.only = TRUE)})

#
# Directory
#
rdata_name <- "SP500ConstituentsHistory.RData"
var_name <- "sp500"
dir <- "C:/Users/KE/OneDrive/Investment/Data/SP500 Constituents/History Master"
url <- "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"

#
# Download data
#
tmp <- htmltab(doc = url, which = "//th[text() = 'Security']/ancestor::table")
tmp$`Ticker symbol` <- gsub("\\.", "-", tmp$`Ticker symbol`)     # Change to Yahoo style
tmp$`Load Date` <- Sys.Date()

#
# Save data
#
setwd(dir)
ifelse(file.exists(rdata_name), load(rdata_name), "file created.")
ifelse(exists(var_name), sp500 <- dplyr::bind_rows(sp500, tmp), sp500 <- tmp)
sp500 <- sp500[!duplicated(sp500),]
save(sp500, file = rdata_name, compress = "xz", compression_level = 9)

#
# Check if there is change
#
tiks_1 <- tmp$`Ticker symbol`
tiks_2 <- sp500[sp500$`Load Date` != Sys.Date(),"Ticker symbol"]

comm_tiks <- intersect(tiks_1, tiks_2)
new_tiks <- tiks_1[!(tiks_1 %in% comm_tiks)]
rmvd_tiks <- tiks_2[!(tiks_2 %in% comm_tiks)]

ifelse(length(new_tiks) == 0 & length(rmvd_tiks) == 0,
       "No ticker is added or removed from SP 500.",
       paste0("New tickers add: ", paste0(new_tiks, collapse = ","),
              " | tickers removed: ", paste0(rmvd_tiks, collapse = ",")))
#
# Write data to csv
#
#setwd(dir)
#load(rdata_name)

curr_dir <- "C:/Users/KE/OneDrive/Daily Operation"
setwd(curr_dir)
write.csv(tmp, "Current sp500.csv")
