# Loading lookup dataset
print("Started Loading the dataset")
pcd_lsoa_mapping = read.csv(paste0(lookup_dataset_mapping,"lookup.csv"))

#### ----------- Started Cleaning Lookup----------- ######
# Checking the null values in each columns
colSums(is.na(pcd_lsoa_mapping))

## Removing all blank rows and taking only complete rows
pcd_lsoa_mapping_cln = subset(pcd_lsoa_mapping, pcd_lsoa_mapping$lsoa11cd != "")

# Selecting only required columns 
location_pcd=select(pcd_lsoa_mapping_cln, pcd7, lsoa11cd, lsoa11nm, ladnm, ladcd, msoa11nm, msoa11cd)
# Checkig nULLS
location_null = subset(pcd_lsoa_mapping, pcd_lsoa_mapping$lsoa11cd != "") #10608 postcodes no lsoa

# Removing spaces from postcode to map with lsoa
location_pcd$pcd7 = gsub(" ","",location_pcd$pcd7)

### Data validation 
## Checking duplicates in PCD
sum(duplicated(location_pcd$pcd7)) # 0 DUPLICATES


print("Started cleaning lookup dataset")
#### -----------  Cleaning Completed for Lookup----------- ######

# Checkpoint 1 Location DIM
write.csv(location_pcd, paste0(lookup_cleaned_dir,"location_pcd.csv"), row.names = FALSE)

### Load if needed
location_pcd=read.csv(paste0(lookup_cleaned_dir,"location_pcd.csv"))

# Checkpoint Location Dimension
print("Generating LAD dimension")
lad_dim = location_pcd %>% select(ladcd, ladnm) %>% distinct()
lad_dim$ladid <- sapply(unique(lad_dim$ladcd), digest)
# Checkpoint 4 Location DIM
write.csv(lad_dim, paste0(dimensions_path,"lad_dim.csv"), row.names = FALSE)
print("Successfully generated LAD dimension")

print("Generating MSOA dimension")
# seelcting unique mosa to creeate msoa dim
msoa_dim = location_pcd %>% select(msoa11cd, msoa11nm, ladcd) %>% distinct()
# Removing duplicated rows ### Integrity 
msoa_dim = msoa_dim[!duplicated(msoa_dim$msoa11cd), ] # Northern Ireland output
msoa_dim$msoa_id <- sapply(unique(msoa_dim$msoa11cd), digest)
msoa_dim = merge(msoa_dim, lad_dim, by="ladcd")
msoa_dim=subset(msoa_dim, select = -c(ladcd,ladnm))
write.csv(msoa_dim, paste0(dimensions_path,"msoa_dim.csv"), row.names = FALSE)
print("Successfully generated MSOA dimension")

print("Generating LSOA dimension")
# seelcting unique mosa to creeate msoa dim
lsoa_dim = location_pcd %>% select(lsoa11cd, lsoa11nm, ladcd, msoa11cd) %>% distinct()
# Removing duplicated rows ### Integrity 
lsoa_dim = lsoa_dim[!duplicated(lsoa_dim$lsoa11cd), ] # Northern Ireland output
lsoa_dim$lsoa_id <- sapply(unique(lsoa_dim$lsoa11cd), digest)
lsoa_dim = merge(lsoa_dim, msoa_dim, by="msoa11cd")
lsoa_dim=subset(lsoa_dim, select = -c(msoa11cd,ladcd, msoa11nm))
write.csv(lsoa_dim, paste0(dimensions_path, "lsoa_dim.csv"), row.names = FALSE)
print("Successfully generated LSOA dimension")
