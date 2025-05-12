
print("Crime Dataset Setting Paths")

# Getting base directory
year_base = basename(year_dir)
# checking the lenght of base dir 
length(year_base)

# Dataframe to store crime dataset report
crime_dataset_report = data.frame()
# loop through each CSV file, read it into R, and append it to the merged data frame
print("Started Loading monthly and merging to yearly crime data files")
for (year in year_base){
  # defining path
  print(paste("Started merging monthly files for", year))
  path_year=gsub(" ","", paste0(dataset,year,"/"))
  # getting all csv files in the path
  csv_files <- list.files(path =path_year, pattern = "*.csv", recursive = TRUE)
  # For merging all yearly month files
  merged_data <- data.frame()
  
  for (file in csv_files) {
    # reading the data from the csv files
    data <- fread(gsub(" ","", paste(path_year,file)))
    # Merging the monthly files
    merged_data <- rbind(merged_data, data)
  }
  # Checkpoint 1 Saving data
  write.csv(merged_data, paste0(merge_dir,"crime_merged_",year,".csv"), row.names = FALSE)
  
  print(paste("Started cleaning merged monhtly crime data of", year))
  #### ----------- Started Cleaning ----------- ######
  
  # Checking the null values in each columns
  colSums(is.na(merged_data))
  
  # Identify rows with complete data
  complete_rows <- complete.cases(merged_data$`LSOA code`)
  
  # Subset the data to rows with complete data
  df_complete <- merged_data[complete_rows, ]
  
  # Subset the data to rows with missing data
  df_na <- merged_data[!complete_rows, ]
  
  # Checking Northern Ireland has LSOA in the LSOA column in the dataset
  df_filtered <- merged_data %>% 
    filter(grepl("Northern Ireland", `Reported by`))
  # df_na missing dataframe and filtered dataframe contains same number of rows
  
  # Checking how many blank rows are there in LSOA
  blank_lsoa_crime = sum(df_complete$`LSOA code` == "")
  # Checking all the data with blank rows
  df_complete_blank = subset(df_complete, df_complete$`LSOA code` == "")
  # Checking that unique value Reported bY station
  unique(df_na$`Reported by`)
  # Output [1] "Police Service of Northern Ireland" - 
  # Northen Ireland Do not have LSOA code in the taken dataset 
  # So removing Northern Ireland from the study
  # Removing all the rows with LSOA as blank as Location column with the correspondiong data is NULL
  df_complete = subset(df_complete, df_complete$`LSOA code` != "")
  
  # Checking the rows with duplicated Crime 
  ### 
  duplicate_crime_id=sum(duplicated(df_complete$`Crime ID`))
  
  # Data with only distinct crime ID(removed duplicates)
  df_complete = distinct(df_complete, `Crime ID`, .keep_all = TRUE)
  
  
  # Selecting only required columns Crime.ID, Month, LSOA.code, Crime.type
  crime_dim=select(df_complete, Month,`LSOA code`, `Crime type`)
  # checking null values in all columns
  colSums(is.na(crime_dim))
  
  print(paste("Cleaning completed for crime data", year))
  ########## ------- Cleaning Completed -------
  
  print("Getting time from Crime")
  #### Time Dimension time creation ---- ####
  #### Generating time_dim from crime and property sales. Getting unique
  time_dim <- data.frame(year = unique(format(as.Date(crime_dim$Month, format = "%Y"), "%Y")))
  # Generating hash id for the time dim
  time_dim$time_id = digest(as.character(time_dim$year))
  
  file_path = paste0(dimensions_path,"time_dim.csv")
  # check if the file exists
  if (file.exists(file_path)) {
    # if the file exists, append the data
    # load the time_dimension data
    time_dim_e = read.csv(file_path)
    time_dim=rbind(time_dim, time_dim_e)
    print("Found time dimension file")
    write.csv(time_dim, file_path, row.names = FALSE)
    print("Successfully Added the year to time dimension file")
  } else {
    # if the file does not exist, create a new file and write the data
    print("Time dimension file not found. Creating a new one !!!")
    print(paste0("Time Dimension path =", file_path))
    write.csv(time_dim, file_path, row.names = FALSE)
  }
  print("Successfully added the time to time demension file")
  ####### --- Completed Time DIM GEN ----- ######
  
  crime_dataset_details = data.frame(year = year,
                                     total_obs = nrow(merged_data),
                                     initial_cols = ncol(merged_data),
                                     northern_ireland_rows = nrow(df_filtered),
                                     total_blank_rows = blank_lsoa_crime,
                                     na_rows = nrow(df_na),
                                     duplicated_rows = duplicate_crime_id,
                                     total_obs_after_cleaning = nrow(crime_dim),
                                     total_cols_after_cleaning = ncol(crime_dim)
  )
  
  crime_dataset_report = rbind(crime_dataset_report, crime_dataset_details)
  print(paste("Saving cleaned data for",year))
  # Checkpoint 2 Saving cleaned data 
  write.csv(crime_dim, paste0(cleaned_dir,"crime_dimension_",year,"_cln",".csv"), row.names = FALSE)
  
  
}
print("Details for Dataset report is saved")
write.csv(crime_dataset_report, paste0(reports_dir, "crime_dataset_details_report.csv"), row.names = FALSE)

print("Generating crime type dimension")
crime_type = crime_dim %>% select(`Crime type`) %>% distinct()
crime_type$crime_id <- sapply(unique(crime_type$`Crime type`), digest)
# Checkpoint 4 Crime DIM
colnames(crime_type)[1]=c("crime_type")
write.csv(crime_type, paste0(dimensions_path, "crime_type_dim.csv"), row.names = FALSE)

csv_files <- list.files(path =cleaned_dir, pattern = "*.csv", recursive = TRUE)

for (file in csv_files) {
  # reading the data from the csv files
  print(paste("Loading ", file))
  crime_dim <- read.csv(gsub(" ","", paste(cleaned_dir, file)))
  print("Loading lSOA dimension file")
  # load the lsoa dim data
  lsoa_dim = read.csv(paste0(dimensions_path,"lsoa_dim.csv"))
  print("Loading time dimension file")
  # load the time_dimension data
  time_dim = read.csv(paste0(dimensions_path,"time_dim.csv"))
  print("Loading crime type dimension file")
  crime_type = read.csv(paste0(dimensions_path,"crime_type_dim.csv"))
  
  # Creating the year column . extracting from Month column
  ### Transformation 1
  ## Extracting oNly year 
  crime_dim$year <- substr(crime_dim$Month, 1,  4)
  file_year = unique(format(as.Date(crime_dim$year, format = "%Y"), "%Y"))
  crime_data_subset=subset(crime_dim, select = c(year, LSOA.code, Crime.type))
  # Merging LSOA data and Crime Data with LSOA code
  print("Merging Crime data with LSOA dimension")
  crime_merge = merge(crime_data_subset, lsoa_dim, by.x="LSOA.code", by.y="lsoa11cd", all.x=TRUE)
  print("Merging Crime data with Time dimension")
  crime_merge = merge(crime_merge, time_dim, by.x="year", by.y="year")
  print("Merging crime data with Crime Type dimension")
  crime_merge = merge(crime_merge, crime_type, by.x="Crime.type", by.y="crime_type")
  print(paste("Saving the merged  Crime data for", file_year))
  write.csv(crime_merge, paste0(dimensions_merged,"crime_merge_",file_year ,".csv"), row.names = FALSE)
  print(paste("Successfully Merged Crime data with all dimesnions for", file_year))
}


# dbWriteTable(conn, "crime_type_dimension", crime_type, overwrite = FALSE, append=TRUE)


