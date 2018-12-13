source("Helper/db_helper.R")
library(magrittr)
options(scipen = 999)

##
# connection for database
##
db_obj <- list(
  srv = "192.168.2.200",
  prt = 3307,
  dbn = "FinDB",
  id = "dspeast2",
  pwd = "yuheng"
)

##
# option chain data
##
yoc_dir <- 'C:/Users/Windows/OneDrive/Investment/Data/HBH Yahoo Option Chain/History Master/YOC/'
data_names <- expand.grid(
  c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"),
  c("2016", "2017", "2018")
)

##
# start processing
##
res <- lapply(1:nrow(data_names), function(i) {
  yocf <- paste0(yoc_dir, "YahooOptionChain-", data_names[i,2], data_names[i,1], ".RData")
  print(paste0("Processing ", yocf))
  
  if(file.exists(yocf)){
    load(yocf)
    
    dataset_name <- paste0("yoc_", data_names[i,2], data_names[i,1])
    if(exists(dataset_name)){
      dataset <- eval(parse(text = dataset_name))
      dataset <- dataset %>% 
        dplyr::mutate(
          LoadDateTime = format(LoadDateTime, "%Y-%m-%d %H:%M:%S"),
          MarketDateTime = format(MarketDateTime, "%Y-%m-%d %H:%M:%S")
        )
      WriteDataToSS(db_obj, dataset, "kmin_yoc", apd = TRUE)
    }
  }
  
})