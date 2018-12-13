#
# The intention of this file is to download html file as PDF from Barchart.com
#
# By Ke Min 2017/02/17
#
root.dir <- "C:/Users/KE/OneDrive/Investment/Data/Barchart Option/"
wkhtml2pdf_dir <- "C:\\wkhtmltopdf\\bin\\wkhtmltopdf"

SaveData <- function(){
  print(i)
  data_us_dir <- paste(root.dir, "US", sep="")
  web_html_us <- "https://www.barchart.com/options/highest-implied-volatility"
  pdf_us <- paste("BarchartIVTable_us_",format(Sys.time(), "%Y%m%d%H%M%S"),".pdf",sep="")
  setwd(data_us_dir)
  shell(paste(wkhtml2pdf_dir, web_html_us, pdf_us, sep=" "))
  
  data_ca_dir <- paste(root.dir, "CA", sep="")
  web_html_ca <- "https://www.barchart.com/ca/options/highest-implied-volatility"
  pdf_ca <- paste("BarchartIVTable_ca_",format(Sys.time(), "%Y%m%d%H%M%S"),".pdf",sep="")
  setwd(data_ca_dir)
  shell(paste(wkhtml2pdf_dir, web_html_ca, pdf_ca, sep=" "))
}

for(i in 1:150){
  SaveData()
  Sys.sleep(3600)
}
