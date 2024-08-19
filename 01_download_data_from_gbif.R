# A script to download data from gbif

library(tidyverse)
library(rgbif)
library(writexl)

taxon <- c("Diogenidae", 
           "Entomobrydiae",
           "Neanuridae",
           "Tityus",
           "Arhynchobatidae",
           "Dipsadidae",
           "Harengula",
           "Opisthonema",
           "Thozetella",
           "Conchocarpus",
           "Eugenia",
           "Gaylussacia",
           "Harpalyce",
           "Iridaceae",
           "Lepismium",
           "Oocephalus",
           "Pilosocereus",
           "Prosthechea",
           "Tillandsia",
           "Tocoyena")

taxon_rank <- c("family",
                "family",
                "family",
                "genus",
                "family",
                "family",
                "genus",
                "genus",
                "genus",
                "genus",
                "genus",
                "genus",
                "genus",
                "family",
                "genus",
                "genus",
                "genus",
                "genus",
                "genus",
                "genus")


for(i in 1:length(taxon)){
  print(i)
  #Use the name_suggest function to get the gbif taxon key
  tax_key <- name_suggest(q = taxon[i], rank = taxon_rank[i])
  
  if(length(tax_key) > 0){
    #Sometimes groups have multiple taxon keys, in this case three, so we will check how many records are available for them
    lapply(tax_key$key, "occ_count")
    
    #Here the firsrt one is relevant, check for your group!
    tax_key <- tax_key$key[1]
    # 
    # # Download data for Neotropics
    # ## The extent of Morrone's 2014 bioregionalization
    # study_a <-"POLYGON((-34.7 32.8, -117.2 32.8, -117.2 -55.8, -34.7 -55.8, -34.7 32.8))"
    # 
    # dat  <- occ_search(taxonKey = tax_key, return = "data", hasCoordinate = T,
    #                    geometry = study_a, limit = 250000)
    # write_xlsx(dat, paste("input/", "redownload_", taxon[i], ".xlsx", sep = ""))
    
    # THis is a similar download to get the API
    occ_download(sprintf("taxonKey = %s", tax_key),
                 "hasCoordinate = TRUE",
                 "decimalLatitude <= 35",
                 "decimalLongitude <= -33",
                 pwd = "YOURPW",
                 user= "YOURUSERNAME",
                 email = 'YOUREMAIL')
    Sys.sleep(time = 60)
  }else{
    print(paste(taxon[i], " - no records found"))
  }
}


