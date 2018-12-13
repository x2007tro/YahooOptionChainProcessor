##
# Connect to MariaDB using connection string
##
ConnMySql <- function(db_obj){
  conn <- DBI::dbConnect(drv = RMariaDB::MariaDB(),
                         user = db_obj$id,
                         password = db_obj$pwd,
                         dbname = db_obj$dbn,
                         host = db_obj$srv,
                         port = db_obj$prt)
  return(conn)
}

##
# Read a table from sel server db
##
ReadDataFromSS <- function(db_obj, tbl_name){
  conn <- ConnMySql(db_obj)
  df <- DBI::dbReadTable(conn, tbl_name)
  DBI::dbDisconnect(conn)  
  return(df)
}

##
# Write a table to sql server db
##
WriteDataToSS <- function(db_obj, data, tbl_name, apd = FALSE){
  conn <- ConnMySql(db_obj)
  df <- DBI::dbWriteTable(conn, name = tbl_name, value = data,
                          append = apd, overwrite = !apd, row.names = FALSE)
  DBI::dbDisconnect(conn) 				  
  return(df)
}