# a script to visualize the raw and cleaned records
library(tidyverse)
library(raster)
library(viridis)
library(ggthemes)
library(speciesgeocodeR)

# load data
dat <- read_csv("output/all_records.csv") %>% 
  filter(!is.na(decimalLongitude)) %>% 
  filter(!is.na(decimalLatitude))

dat_cl <-  dat %>% 
  filter(summary)

be <- raster("input/ABROCOMIDAE_ABROCOMIDAE.tif")

# define projections
behr <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'
wgs1984 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"


# Figure one - total
# convert data
pts_rw <- dat[, c("decimalLongitude", "decimalLatitude")]%>%
  SpatialPoints(proj4string = CRS(wgs1984))%>%
  spTransform(behr)
pts_rw <- data.frame(accepted_name_species = dat$species,
                  coordinates(pts_rw))

pts_cl <- dat_cl[, c("decimalLongitude", "decimalLatitude")]%>%
  SpatialPoints(proj4string = CRS(wgs1984))%>%
  spTransform(behr)
pts_cl <- data.frame(accepted_name_species = dat_cl$species,
                     coordinates(pts_cl))

# generate raster with species occurrence
abu_rw <- RichnessGrid(x = pts_rw, ras = be, type = "abu")
abu_cl <- RichnessGrid(x = pts_cl, ras = be, type = "abu")

plo <- abu_rw - abu_cl

plo <-data.frame(rasterToPoints(plo))
# 
# plo_rw <-data.frame(rasterToPoints(abu_rw))%>%
#   # filter(layer > 0 ) %>% 
#   mutate(dataset = "Raw")
# 
# plo_cl <-data.frame(rasterToPoints(abu_cl))%>%
#   # filter(layer > 0 ) %>% 
#   mutate(dataset = "Filtered")
# 
# plo <- bind_rows(plo_rw, plo_cl)

# background map
world.inp  <- suppressWarnings(rnaturalearth::ne_download(scale = 50, 
                                                          type = 'land', 
                                                          category = 'physical',
                                                          load = TRUE))
world.behr <- spTransform(world.inp, CRS(behr)) %>% fortify()


# plot
ggplot()+
  geom_polygon(data = world.behr,
               aes(x = long, y = lat, group = group), fill = "transparent", color = "black")+
  geom_tile(data = plo, aes(x = x, y = y, fill = log(layer)), alpha = 0.8)+
  scale_fill_viridis(name = "Number of\nrecords", direction = -1, na.value = "transparent",
                     breaks = c(log(1), log(10), log(100), log(1000), log(5000)),
                     labels = c(1,10,100,1000,5000))+
  xlim(-12000000, -3000000)+
  ylim(-6500000, 4500000)+
  coord_fixed()+
  theme_bw()+
  theme(legend.position = "bottom",
        legend.key.width = unit(1.5, "cm"),
        axis.title = element_blank())#+
  # facet_wrap(.~ dataset, ncol = 2)

ggsave("output/figure_number_of_records.jpg", height = 8, width=8)

# Figure 2
plo <- dat %>% 
  select(-coordinateUncertaintyInMeters, -taxon, -countryCode, -gbifID,
         -class,
         -genus, -taxonRank,
         -basisOfRecord, 
         -individualCount, -year,
         -family, -.summary, 
         -summary) %>% 
  rename(decimalspecies = species) %>% 
  pivot_longer(cols = -contains("decimal"), names_to = "test", values_to = "test_result") %>% 
  filter(!test_result) %>% 
  mutate(test = recode(test,
                      .urb = "Urban areas",
                      coordinate_base = "Basis of record",
                      .dpl = "Duplicates",
                      record_id = "Identification level",
                      record_age = "Collection year",
                      coordinate_precision = "Coordinate precision",
                      .cap = "Capitals",
                      .inst = "Biodiversity institutions",
                      .cen = "Political centroids",
                      individual_count = "Individual count",
                      .sea = "Sea/land area",
                      .zer = "Zeros",
                      .equ = "Equal lat/lon")) %>% 
  filter(test != "Equal lat/lon")
  


plo <- split(plo, f = plo$test)

plo <-  lapply(plo, 
               function(k){
                 pts <- k[, c("decimalLongitude", "decimalLatitude")]%>%
                   SpatialPoints(proj4string = CRS(wgs1984))%>%
                   spTransform(behr) %>% 
                   coordinates()
                 pts <-  data.frame(test = k$decimalspecies,
                                    pts)
                 out <- pts %>% 
                   RichnessGrid(ras = be, type = "abu") %>% 
                   rasterToPoints() %>% 
                   data.frame()})

plo <- bind_rows(plo, .id = "test")

plo <- plo %>%
  mutate(test = factor(test, levels = c("Basis of record",
                                        "Collection year",
                                        "Coordinate precision",
                                        "Identification level",
                                        "Individual count",
                                        "Capitals", 
                                        "Biodiversity institutions",
                                        "Duplicates", 
                                        "Political centroids",
                                        "Equal lat/lon",
                                        "Sea/land area",
                                        "Urban areas", 
                                        "Zeros")))

ggplot()+
  geom_polygon(data = world.behr,
               aes(x = long, y = lat, group = group), fill = "transparent", color = "black")+
  geom_tile(data = plo, aes(x = x, y = y, fill = log(layer)), alpha = 0.8)+
  scale_fill_viridis(name = "Number of\nrecords", direction = -1, na.value = "transparent",
                     breaks = c(log(1), log(10), log(100), log(1000), log(5000)),
                     labels = c(1,10,100,1000,5000))+
  xlim(-12000000, -3000000)+
  ylim(-6500000, 4500000)+
  coord_fixed()+
  theme_bw()+
  theme(legend.position = "bottom",
        legend.key.width = unit(1.5, "cm"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  facet_wrap(.~ test)

ggsave("output/figure_number_of_records_split.jpg", height = 10, width=8)
