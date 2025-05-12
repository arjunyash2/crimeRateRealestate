#### Libraries
install.packages("data.table")
install.packages("digest")
library(data.table)
library(dplyr)
library(digest)

# get the list of all folders in the directory drop
year_dir = list.dirs("/Users/arjun/Documents/ADMP/Datasets/CrimeDataset", recursive = FALSE)
merge_dir = "/Users/arjun/Documents/ADMP/Datasets/CrimeDatasetMerged/"
cleaned_dir = "/Users/arjun/Documents/ADMP/Datasets/CrimeDatasetCleaned/"
dimensions_path ="/Users/arjun/Documents/ADMP/Dimensions/"
dataset = "/Users/arjun/Documents/ADMP/Datasets/CrimeDataset/"
# Getting base directory
year_base = basename(year_dir)
# checking the lenght of base dir 
length(year_base)

# Dataframe to store crime dataset report
crime_dataset_report = data.frame()
# loop through each CSV file, read it into R, and append it to the merged data frame
for (year in year_base){
  # defining path
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
  ########## ------- Cleaning Completed -------
  
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
    time_dim_e = read.csv(paste0(dimensions_path,"time_dim.csv"))
    time_dim=rbind(time_dim, time_dim_e)
    write.csv(time_dim, file_path, row.names = FALSE)
    
  } else {
    # if the file does not exist, create a new file and write the data
    write.csv(time_dim, file_path, row.names = FALSE)
  }
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
  
  # Checkpoint 2 Saving cleaned data 
  write.csv(crime_dim, paste0(cleaned_dir,"crime_dimension_",year,"_cln",".csv"), row.names = FALSE)
  
  
}
