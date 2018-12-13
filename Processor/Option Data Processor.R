lib <- c("lubridate","dplyr")
lapply(lib, function(x){library(x, character.only = TRUE)})

#
# Parameters
#
yr <- "2018"
mth <- "12"
op_var_nm <- paste0("yoc_", yr, mth)

#
# Setup directory
#
input_dir <- "C:/Users/Ke/Desktop/Strategy - MinuteByMinuteOption/OptionChains/History/"
output_dir <- "C:/Users/Ke/OneDrive/Investment/Data/HBH Yahoo Option Chain/History Master/YOC"
curr_tz <- "AST"   # It has to be manually adjusted
op_data_file <- paste0("YahooOptionChain-", yr, mth, ".RData")
all_fns <- list.files(path = input_dir, pattern = ".csv", full.names = TRUE)

ManiYOC <- function(fn, yr, mth){
  print(paste0("Process ", fn))
   
  if(grepl(paste0(yr, mth), fn)){

    dta <- read.csv(fn, sep = ";", stringsAsFactors = FALSE)
    
    #
    # Daylight Saving Time (ADT) March, YYYY - November, YYYY
    #
    # ADT : Load Time 11:30 AM = Market Time 09:30 AM
    # ADT : Load Time 06:00 PM = Market time 04:00 PM
    # 
    
    #
    # Atlantic Standard Time (AST) November, YYYY - March, YYYY+1
    #
    # AST : Load Time 10:30 AM = Market Time 09:30 AM
    # AST : Load Time 05:00 PM = Market Time 04:00 PM
    #
    std_load_date <- unique(dta$LoadDate)[1]
    
    if(curr_tz == "AST"){
      beg_dt <- as.POSIXct(paste0(std_load_date, " ", "10:30:00"), format = "%Y-%m-%d %H:%M:%S")
      end_dt <- as.POSIXct(paste0(std_load_date, " ", "17:00:00"), format = "%Y-%m-%d %H:%M:%S")
    } else if(curr_tz == "ADT"){
      beg_dt <- as.POSIXct(paste0(std_load_date, " ", "11:30:00"), format = "%Y-%m-%d %H:%M:%S")
      end_dt <- as.POSIXct(paste0(std_load_date, " ", "18:00:00"), format = "%Y-%m-%d %H:%M:%S")
    } else {
      print("Error: Unknown time zone. Adjust cutoff time before proceed.")
    }
    
    dta$LoadDateTime <- as.POSIXct(paste0(dta$LoadDate, " ", dta$LoadTime), format = "%Y-%m-%d %H:%M:%S")
    dta$MarketDateTime <- as.POSIXct(paste0(dta$MarketDate, " ", dta$MarketTime), format = "%Y-%m-%d %H:%M:%S", tz = "EST")
    dta$ExpDate <- as.Date(dta$ExpDate, format = "%Y-%m-%d")
    dta$OpenInterest <- dta$Open.Interest
    dta$ImpliedVolatility <- as.numeric(gsub("%","",dta$Implied.Volatility))/100
    
    dta_1 <- dta[,c("LoadDateTime", "MarketDateTime", "Symbol", "ExpDate", "Type", "Strike",
                    "Last", "Bid", "Ask", "Volume", "OpenInterest", "ImpliedVolatility")]
    
    dta_2 <- dta_1[dta_1$LoadDateTime >= beg_dt & dta_1$LoadDateTime <= end_dt, ]
    
    return(dta_2)
  } else {
    return(NULL)
  }
}
run_results <- lapply(all_fns, ManiYOC, yr, mth)
run_results_nona <- run_results[!sapply(run_results, is.null)]   # Remove null element from list
internal_output <- dplyr::bind_rows(run_results_nona)

#
# Read object from storage
#
setwd(output_dir)
ifelse(file.exists(op_data_file), load(op_data_file), paste0("File - ",  op_data_file, " created."))    
if(exists(op_var_nm)){
  master_data <- get(op_var_nm)                                               # Obtain data by object name
  master_data1 <- dplyr::bind_rows(master_data, internal_output)
  #master_data1 <- master_data1[!duplicated(master_data1), ]
} else {
  master_data1 <- internal_output
}

#
# Save object to storage
#
assign(op_var_nm, master_data1)
#save(list = op_var_nm, file = op_data_file, compress = "xz", compression_level = 9)
save(list = op_var_nm, file = op_data_file, compress = "bzip2", compression_level = 9)

#
# test if data there
#
print(unique(as.Date(master_data1$LoadDateTime)))
