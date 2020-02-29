# Automated conservation assessment

library(ConR)
library(tidyverse)
library(rredlist)
library(jsonlite)

# load and prepare data
dat <- read_csv("output/all_records.csv") %>% 
  filter(!is.na(decimalLongitude)) %>% 
  filter(!is.na(decimalLatitude))

dat_cl <-  dat %>% 
  filter(summary)

# Automated assessment
## raw
rw_in <- dat%>%
  dplyr::select(ddlat = decimalLatitude,
                ddlon = decimalLongitude, 
                tax = species) %>% 
  distinct() %>% 
  filter(!is.na(tax))

rw_in <- rw_in %>% filter(ddlat >-80) # there is one erroneous record that makes the automated assessment crash

## filtered
cl_in <- dat_cl%>%
  dplyr::select(ddlat = decimalLatitude,
                ddlon = decimalLongitude, 
                tax = species) %>% 
  distinct()


# AUtomated assessment
## raw
# splist <- unique(rw_in$tax)
# 
# for(i in 1:length(splist)){
#   print(paste(i, length(splist), sep = "/"))
#   sub <- rw_in %>% filter(tax == splist[i])
#   
#   out <- IUCN.eval(sub)
#   
#   if(i == 1){
#     write_csv(out, "output/automated_assessment_raw.csv")
#   }else{
#     write_csv(out, "output/automated_assessment_raw.csv", append = TRUE)
#   }
# }
# 
# ## filtered
# splist <- unique(cl_in$tax)
# 
# for(i in 1:length(splist)){
#   print(paste(i, length(splist), sep = "/"))
#   sub <- cl_in %>% filter(tax == splist[i])
#   
#   out <- IUCN.eval(sub)
#   
#   if(i == 1){
#     write_csv(out, "output/automated_assessment_clean.csv")
#   }else{
#     write_csv(out, "output/automated_assessment_clean.csv", append = TRUE)
#   }
# }
# 

# IUCN assessment for the species
iucn.key <- "01524b67f4972521acd1ded2d8b3858e7fedc7da5fd75b8bb2c5456ea18b01ba"

sp.list <- rw_in$tax %>% 
  as.character() %>% 
  unique()

#get conservation status from IUCN
for(i in 1:length(sp.list)){
  print(i)
  pick <- jsonlite::fromJSON(rl_search_(sp.list[i], key = iucn.key))$result
  
  if(length(pick) >0){
    if(i == 1){
      write_csv(pick, "output/iucn_assessment.csv")
    }else{
      write_csv(pick, "output/iucn_assessment.csv", append = TRUE)
    }
  }

  Sys.sleep(1)
}

# Load assessments
rw <- read_csv("output/automated_assessment_raw.csv") %>% 
  select(taxa, EOO, AOO, Category_CriteriaB, Category_code)
names(rw) <- paste("raw", names(rw), sep = "_")

cl <- read_csv("output/automated_assessment_clean.csv")
names(cl) <- gsub("filtered_", "", names(cl))
cl <- select(cl, taxa, EOO, AOO, Category_CriteriaB, Category_code)
names(cl) <- paste("flag", names(cl), sep = "_")

iucn <- read_csv("output/iucn_assessment.csv") %>% 
  select(scientific_name, published_year, category, criteria, population_trend, aoo_km2, eoo_km2)
names(iucn) <- paste("iucn", names(iucn), sep = "_")

tax <- read_csv("output/all_records.csv") %>% 
  select(taxon, species) %>% 
  distinct()

## join the three datasets and save as the full data for the supplementary
dat <- rw %>% 
  left_join(cl, by = c("raw_taxa" = "flag_taxa")) %>% 
  left_join(iucn, by = c("raw_taxa" = "iucn_scientific_name")) %>% 
  left_join(tax, by = c("raw_taxa" = "species")) 

sp_count <-  dat %>% 
  group_by(taxon) %>% 
  mutate(threatened = iucn_category %in% c("EX", "CR", "EN", "VU")) %>% 
  mutate(eval = iucn_category %in% c("EX", "CR", "EN", "VU", "NT", "LC")) %>% 
  mutate(spnum = !is.na(iucn_category)) %>% 
  summarize(iucn_spnum = sum(spnum),
            iucn_frac_eval = round(mean(eval, na.rm = TRUE) * 100, 1),
            iucn_frac_threat = round(mean(threatened, na.rm = TRUE) * 100, 1),
            raw_spnum = sum(!is.na(raw_Category_CriteriaB)),
            flag_spnum = sum(!is.na(flag_Category_CriteriaB)))

dat <-  dat %>% 
  mutate(flag_EOO = ifelse(is.na(flag_EOO), flag_AOO, flag_EOO)) %>% 
  mutate(raw_EOO = ifelse(is.na(raw_EOO), raw_AOO, raw_EOO)) %>% 
  mutate(EOO_change = ((flag_EOO - raw_EOO) / raw_EOO *100))%>% 
  mutate(AOO_change = ((flag_AOO - raw_AOO) / raw_AOO *100)) %>% 
  mutate(raw_status = ifelse(raw_Category_CriteriaB == "LC or NT", "not_threatened", "possibly_threatened"))%>% 
  mutate(flag_status = ifelse(flag_Category_CriteriaB == "LC or NT", "not_threatened", "possibly_threatened"))

# remove potential duplicates
dat <- dat %>% 
  distinct()

write_csv(dat, "output/supplement_full_results_conservation_assessment.csv")



iucn <- dat %>% 
  filter(!iucn_category %in% c("DD", "EX", "NA")) %>% 
  filter(!is.na(iucn_category)) %>% 
  mutate(iucn_category = ifelse(iucn_category %in% c("LC", "NT"), "LC or NT", iucn_category)) %>% 
  mutate(iucn_status = ifelse(iucn_category == "LC or NT", "not_threatened", "possibly_threatened")) %>% 
  mutate(raw_iucn_agreement = raw_status == iucn_status) %>% 
  mutate(flag_iucn_agreement = flag_status == iucn_status) %>% 
  group_by(taxon) %>% 
    summarize(raw_iucn_match = round(mean(raw_iucn_agreement, na.rm = TRUE) * 100, 1),
              flag_iucn_match = round(mean(flag_iucn_agreement, na.rm = TRUE) * 100, 1)
              )



## select the relevant columns for the table in the paper
out <- dat %>% 
  select(taxon,
         iucn_category,
         raw_Category_CriteriaB,
         raw_status,
         flag_Category_CriteriaB,
         flag_status,
         EOO_change,
         AOO_change) %>% 
  group_by(taxon) %>% 
  summarize(
    raw_frac_threat = round(mean(raw_status == "possibly_threatened") * 100, 1),
    flag_frac_threat = round(mean(flag_status == "possibly_threatened", na.rm = TRUE) * 100, 1),
    flag_median_EOO_change = round(mean(EOO_change, na.rm = TRUE), 1),
    flag_median_AOO_change = round(mean(AOO_change, na.rm = TRUE), 1)) %>% 
    left_join(iucn) %>% 
  full_join(sp_count) %>% 
  select(taxon,
         iucn_spnum,
         iucn_frac_eval, 
         iucn_frac_threat,
         raw_spnum,
         raw_frac_threat,
         raw_iucn_match,
         flag_spnum,
         flag_frac_threat,
         flag_iucn_match,
         flag_median_EOO_change,
         flag_median_AOO_change)

write_csv(out, "output/table_results_conservation_assessment.csv")
