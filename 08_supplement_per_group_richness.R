# a script to generate the suppemebnt for each group
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

# explore what is going on with the high filter fraction taxa
# dat %>%  filter(taxon == "Tityus") %>%  group_by(basisOfRecord, coordinate_base) %>% summarize(num = n()) %>%
#   group_by(coordinate_base) %>% mutate(frac = num / sum(num))
# dat %>%  filter(taxon == "Dipsadidae") %>%  group_by(basisOfRecord, coordinate_base)  %>% summarize(num = n()) %>%
#   group_by(coordinate_base) %>% mutate(frac = num / sum(num))
# dat %>%  filter(taxon == "Prosthechea") %>%  group_by(basisOfRecord, coordinate_base)  %>% summarize(num = n()) %>%
#   group_by(coordinate_base) %>% mutate(frac = num / sum(num))
# dat %>%  filter(taxon == "Tillandsia") %>%  group_by(basisOfRecord, coordinate_base)  %>% summarize(num = n()) %>%
#   group_by(coordinate_base) %>% mutate(frac = num / sum(num))
# 
# dat %>%  filter(taxon == "Dipsadidae") %>%  group_by(year, record_age)  %>% summarize(num = n()) %>%
#   group_by(record_age) %>% mutate(frac = num / sum(num)) %>%  View()
# 
# dat %>%  filter(taxon == "Diogenidae") %>%  group_by(individualCount, individual_count)  %>% summarize(num = n()) %>%
#   group_by(individual_count) %>% mutate(frac = num / sum(num)) %>%  View()
# dat %>%  filter(taxon == "Harengula") %>%  group_by(individualCount, individual_count)  %>% summarize(num = n()) %>%
#   group_by(individual_count) %>% mutate(frac = num / sum(num)) %>%  View()
# 
# dat %>%  filter(taxon == "Tityus") %>%  group_by(taxonRank, record_id) %>% summarize(num = n()) %>%
#   group_by(record_id) %>% mutate(frac = num / sum(num))
# dat %>%  group_by(taxon, taxonRank, record_id) %>% summarize(num = n()) %>%
#   group_by(record_id) %>% mutate(frac = num / sum(num))
# 
# dat %>%  filter(taxon == "Iridaceae") %>%  filter(!.urb) %>% group_by(species) %>% summarize(num = n()) %>%  arrange(desc(num))

be <- raster("input/ABROCOMIDAE_ABROCOMIDAE.tif")

# define projections
behr <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'
wgs1984 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# background map
world.inp  <- suppressWarnings(rnaturalearth::ne_download(scale = 50, 
                                                          type = 'land', 
                                                          category = 'physical',
                                                          load = TRUE))
world.behr <- spTransform(world.inp, CRS(behr)) %>% fortify()

#cleaned data for main mansucript
plo <- dat %>%
  filter(summary) %>% 
  select(species, taxon, decimalLongitude, decimalLatitude)

plo <- split(plo, f = plo$taxon)

plo <-  lapply(plo, 
               function(k){
                 pts <- k[, c("decimalLongitude", "decimalLatitude")]%>%
                   SpatialPoints(proj4string = CRS(wgs1984))%>%
                   spTransform(behr) %>% 
                   coordinates()
                 pts <-  data.frame(species = k$species,
                                    pts)
                 out <- pts %>% 
                   RichnessGrid(ras = be, type = "spnum") %>% 
                   rasterToPoints() %>% 
                   data.frame()})

plo_cl <- bind_rows(plo, .id = "taxon")
names(plo_cl)[4] <- "layer_cl"

# unfiltered for the supplement
plo <- dat %>%
  select(species, taxon, decimalLongitude, decimalLatitude)

plo <- split(plo, f = plo$taxon)

plo <-  lapply(plo, 
               function(k){
                 pts <- k[, c("decimalLongitude", "decimalLatitude")]%>%
                   SpatialPoints(proj4string = CRS(wgs1984))%>%
                   spTransform(behr) %>% 
                   coordinates()
                 pts <-  data.frame(species = k$species,
                                    pts)
                 out <- pts %>% 
                   RichnessGrid(ras = be, type = "spnum") %>% 
                   rasterToPoints() %>% 
                   data.frame()})

plo_rw <- bind_rows(plo, .id = "taxon")
names(plo_rw)[4] <- "layer_rw"

plo <- full_join(plo_rw, plo_cl, by = c("taxon", "x", "y")) %>% 
  replace_na(list(layer_cl = 0)) %>% 
  mutate(difference = layer_rw - layer_cl)


ggplot()+
  geom_polygon(data = world.behr,
               aes(x = long, y = lat, group = group), fill = "transparent", color = "black")+
  geom_tile(data = plo, aes(x = x, y = y, fill = log(difference)), alpha = 0.8)+
  scale_fill_viridis(name = "Number of\nspecies", direction = 1, na.value = "transparent",
                     breaks = c(log(1), log(5), log(10), log(20), log(30), log(40)),
                     labels = c(1, 5, 10, 20, 30, 40))+
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
  facet_wrap(.~ taxon)

ggsave("output/figure_number_species_richness_difference.jpg", height = 10, width=8)
