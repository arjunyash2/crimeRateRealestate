install.packages("data.table")
install.packages("digest")
#### Libraries
library(data.table)
library(digest)
library(dplyr)
# get the list of all folders in the directory drop
year_dir = list.dirs("/Users/arjun/Documents/ADMP/Datasets/CrimeDataset", recursive = FALSE)
merge_dir = "/Users/arjun/Documents/ADMP/Datasets/CrimeDatasetMerged/"
cleaned_dir = "/Users/arjun/Documents/ADMP/Datasets/CrimeDatasetCleaned/"
dimensions_path ="/Users/arjun/Documents/ADMP/Dimensions/"
dimensions_merged = "/Users/arjun/Documents/ADMP/DimensionMerged/"
dataset = "/Users/arjun/Documents/ADMP/Datasets/CrimeDataset/"
reports_dir = "/Users/arjun/Documents/ADMP/Datasets/DatasetReports/"
lookup_dataset_mapping = "/Users/arjun/Documents/ADMP/Datasets/Lookup/"
lookup_cleaned_dir = "/Users/arjun/Documents/ADMP/Datasets/LookupCleaned/"

source("/Users/arjun/Documents/ADMP/Source/lookup_cleaning.R")
source("/Users/arjun/Documents/ADMP/Source/CrimeData_cleaning.R")
