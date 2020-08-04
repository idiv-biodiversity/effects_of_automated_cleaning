# A script to combine the data from gbif and run the metadata and automated filtering

# libraries
library(tidyverse)
library(countrycode)
library(CoordinateCleaner)

# load and combine data
li <- list.files("input/gbif/", pattern = "_")

dat <- data.frame()

for(i in 1:length(li)){
  print(i)
  sub <- read_delim(paste("input/gbif/", li[i], "/occurrence.txt", sep = ""), delim = "\t", quote = "") %>% 
    mutate_all(as.character)
  if(nrow(sub) > 0){
    quant <- bind_rows(quant, sub[,c("organismQuantity", "organismQuantityType", "occurrenceStatus" )])
    sub$taxon <- str_split(li[i], pattern = "_")[[1]][1]
    sub <- dplyr::select(sub, taxon, decimalLongitude, decimalLatitude,
                  coordinateUncertaintyInMeters, 
                  countryCode, gbifID, species, class, family, genus, taxonRank,
                  year, basisOfRecord, individualCount, organismQuantity, organismQuantityType, occurrenceStatus, hasGeospatialIssues)
    dat <- bind_rows(dat,sub)
    
  }
}

# get the number of records with the columns needed to disambiguate the IndividualCount = 0 issue
sum(!is.na(dat$organismQuantity)) / nrow(dat)
sum(!is.na(dat$organismQuantityType)) / nrow(dat)
sum(!is.na(dat$occurrenceStatus)) / nrow(dat)

test <- dat %>% filter((individualCount == 0))
sum(!is.na(test$organismQuantity)) / nrow(test)
sum(!is.na(test$organismQuantityType)) / nrow(test)
sum(!is.na(test$occurrenceStatus)) / nrow(test)

dat <- dat %>% 
  select(-organismQuantity, -organismQuantityType, -occurrenceStatus, -hasGeospatialIssues)

# meta data filtering
dat <- dat %>% 
  mutate(coordinateUncertaintyInMeters = parse_number(coordinateUncertaintyInMeters)) %>% 
  mutate(decimalLongitude = round(parse_number(decimalLongitude), 4)) %>% 
  mutate(decimalLatitude = round(parse_number(decimalLatitude), 4)) %>%  
  filter(!is.na(species)) %>% # remove entires without species information
  filter(decimalLongitude >= -120)%>% 
  mutate(individualCount = ifelse(individualCount == TRUE, NA, individualCount)) %>%
  mutate(individualCount =  ifelse(individualCount == FALSE, NA, individualCount)) %>% 
  mutate(coordinate_missing =!is.na(decimalLongitude) | !is.na(decimalLatitude)) %>% 
  mutate(coordinate_precision = coordinateUncertaintyInMeters/1000 <= 100 | is.na(coordinateUncertaintyInMeters)) %>% 
  mutate(coordinate_base = basisOfRecord == "HUMAN_OBSERVATION" | 
           basisOfRecord == "OBSERVATION" |
           basisOfRecord == "PRESERVED_SPECIMEN" | 
           is.na(basisOfRecord)) %>% 
  mutate(individual_count = (individualCount > 0 | is.na(individualCount)) &
           (individualCount <= 99 | is.na(individualCount))) %>% 
  mutate(record_age = year > 1945 | is.na(year)) %>% 
  mutate(record_id = taxonRank == "SPECIES" | 
           taxonRank == "SUBSPECIES" |
           taxonRank == "VARIETY" |
           taxonRank == "FORM" |
           is.na(taxonRank)) %>% 
  mutate(countryCode = countrycode(.$countryCode, 
                                   origin =  'iso2c', 
                                   destination = 'iso3c'))

# CoordinateCleaner
dat <- clean_coordinates(x = dat, 
                           lon = "decimalLongitude", 
                           lat = "decimalLatitude",
                           countries = "countryCode", 
                           species = "species",
                           tests = c("capitals", "centroids", 
                                     "equal","gbif", "institutions",
                                     "zeros", "seas", "duplicates", "urban"),
                           seas_ref = buffland) # most test are on by default

# convert .seas flag for the seas taxa
sea2 <- cc_sea(x = as.data.frame(dat), 
               lon = "decimalLongitude", 
               lat = "decimalLatitude", value = "flagged")

dat <- dat %>% 
  mutate(.sea2 = !sea2) %>% 
  mutate(.sea = ifelse(taxon == "Arhynchobatidae" |
                         taxon == "Harengula" |
                         taxon == "Opisthonema" |
                         taxon == "Diogenidae", .sea2, .sea)) %>% 
  dplyr::select(-.sea2)

# summarize the records and taxa remaining
out <- dat %>% 
  mutate(summary = ifelse(coordinate_missing &
                            coordinate_precision &
                            coordinate_base &
                            individual_count &
                            record_age &
                            record_id &
                            .val &
                            .equ &
                            .zer &
                            .cap &
                            .cen &
                            .sea &
                            .urb &
                            .gbf &
                            .inst & 
                            .dpl, TRUE, FALSE))

tot <- out %>% 
  summarize(
    total_records = length(summary),
    total_flags = sum(!summary),
    coordinate_missing = sum(!coordinate_missing),
    coordinate_precision = sum(!coordinate_precision),
    coordinate_base = sum(!coordinate_base),
    individual_count = sum(!individual_count),
    record_age = sum(!record_age),
    record_id = sum(!record_id),
    invalid_coords = sum(!.val),
    equal_coords = sum(!.equ),
    zero_coords = sum(!.zer),
    capital_coords = sum(!.cap),
    centroid_coords = sum(!.cen),
    sea_coords = sum(!.sea),
    urban_coords = sum(!.urb),
    gbif_coords = sum(!.gbf),
    inst_coords = sum(!.inst),
    dupl_coords = sum(!.dpl)) %>% 
  mutate(taxon = "Total")

summary_table <- out %>% 
  group_by(taxon) %>% 
  mutate(total_error = !(.sea & .inst & .zer & .equ)) %>% 
  mutate(total_unfit = !(coordinate_precision&
                            coordinate_base&
                            individual_count&
                            record_age&
                            record_id&
                            .cap&
                            .cen&
                            .urb&
                            .dpl)) %>% 
  summarize(
    total_records = length(summary),
    total_flags = sum(!summary),
    coordinate_missing = sum(!coordinate_missing),
    coordinate_precision = sum(!coordinate_precision),
    coordinate_base = sum(!coordinate_base),
    individual_count = sum(!individual_count),
    record_age = sum(!record_age),
    record_id = sum(!record_id),
    invalid_coords = sum(!.val),
    equal_coords = sum(!.equ),
    zero_coords = sum(!.zer),
    capital_coords = sum(!.cap),
    centroid_coords = sum(!.cen),
    sea_coords = sum(!.sea),
    urban_coords = sum(!.urb),
    gbif_coords = sum(!.gbf),
    inst_coords = sum(!.inst),
    dupl_coords = sum(!.dpl),
    total_error = sum(total_error),
    total_unfit = sum(total_unfit),
    ) %>% 
  bind_rows(tot) %>% 
  mutate(fraction = total_flags / total_records)

# write to disk
write_csv(summary_table, path = "output/summary_table_flags.csv")

write_csv(out, path = "output/all_records.csv")
