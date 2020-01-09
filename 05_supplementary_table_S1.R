# A script to generate supplementary table 1, with the absolute numbers for each flag
library(tidyverse)

tab2 <- read_csv("output/summary_table_flags.csv") %>%  
  mutate(fraction = round(fraction * 100,1))

tab2 <- tab2[,c(1:3,ncol(tab2),4:(ncol(tab2) -1))]

names(tab2) <- c("Taxon",
                 "Total number of records",
                 "Total number of flags",
                 "Fraction of records flagged",
                 "Missing coordinates",
                 "Coordinate precision",
                 "Basis of record",
                 "Number of individuals collected",
                 "Collection year",
                 "Identification level",
                 "Invalid records",
                 "Equal lat/lon",
                 "Zero coordinates",
                 "Capital coordinates",
                 "Political centroids",
                 "Sea coordinates",
                 "Urban areas",
                 "GBIF headquaters",
                 "Biodiversity instiutions",
                 "Duplicates")

write_csv(tab2, "output/supplement_absolute_numbers_flags.csv")
