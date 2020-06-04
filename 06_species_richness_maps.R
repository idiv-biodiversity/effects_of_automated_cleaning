# a script to visualize the raw and cleaned records
library(tidyverse)
library(raster)
library(viridis)
library(ggthemes)
library(speciesgeocodeR)
library(rnaturalearth)

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

# background map
world.inp  <- suppressWarnings(rnaturalearth::ne_download(scale = 110, 
                                                          type = 'land', 
                                                          category = 'physical',
                                                          load = TRUE))
world.behr <- spTransform(world.inp, CRS(behr)) %>% fortify()

world.countries <- rnaturalearth::ne_countries(type = 'countries', 
                                scale = 110)
countries.behr <- spTransform(world.countries, CRS(behr)) %>% fortify()
#cleaned data for main mansucript
plo <- dat %>%
  filter(summary) %>% 
  dplyr::select(species, taxon, decimalLongitude, decimalLatitude)

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
  dplyr::select(species, taxon, decimalLongitude, decimalLatitude)

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

write_csv(plo, "output/specis_richness.csv")

# plots of difference for the main manuscript

## select illustrative taxa

plo <- plo %>% 
  filter(taxon %in% c("Thozetella", "Tillandsia", "Dipsadidae", "Harengula")) %>% 
  filter(difference != 0)

# plot
ggplot()+
  # geom_polygon(data = world.behr,
  #              aes(x = long, y = lat, group = group), 
  #              fill = "transparent", 
  #              color = "black",
  #              size = 0.1)+
  geom_polygon(data = countries.behr,
               aes(x = long, y = lat, group = group), 
               fill = "transparent", 
               color = "grey40",
               size = 0.1)+
  geom_tile(data = plo, aes(x = x, y = y, fill = log(difference)), alpha = 0.8)+
  scale_fill_viridis(name = "Number of\nremoved\nspecies", direction = 1, na.value = "transparent",
                     breaks = c(log(1), log(5), log(10), log(20), log(30), log(40)),
                     labels = c(1, 5, 10, 20, 30, 40))+
  xlim(-12000000, -3000000)+
  ylim(-6500000, 4500000)+
  coord_fixed()+
  theme_bw()+
  theme(legend.position = "right",
        legend.key.height = unit(2.5, "cm"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  facet_wrap(.~ taxon)

ggsave("output/figure_number_species_richness_difference.pdf", height = 10, width=8)
# edit the facet titles seperately to the genera in italics and add the figures

# per species plots for the supplement
# li <- unique(plo$taxon)
# 
# for(i in 1:length(li)){
#   sub <- filter(plo, taxon == li[i]) %>% 
#     pivot_longer(contains("layer"), values_to = "species", names_to = "dataset") %>% 
#     mutate(dataset = recode(dataset, layer_rw = "Raw", layer_cl = "Filtered")) %>% 
#     mutate(dataset = factor(dataset, levels = c("Raw", "Filtered")))
#   
#   ggplot()+
#     geom_polygon(data = world.behr,
#                  aes(x = long, y = lat, group = group), fill = "transparent", color = "black")+
#     geom_tile(data = sub, aes(x = x, y = y, fill = species), alpha = 0.8)+
#     scale_fill_viridis(name = "Number of\nspecies", direction = 1, na.value = "transparent")+
#     xlim(-12000000, -3000000)+
#     ylim(-6500000, 4500000)+
#     coord_fixed()+
#     theme_bw()+
#     theme(legend.position = "bottom",
#           legend.key.width = unit(1.5, "cm"),
#           axis.title = element_blank(),
#           axis.ticks = element_blank(),
#           axis.text = element_blank(),
#           panel.grid.major = element_blank(),
#           panel.grid.minor = element_blank())+
#     facet_wrap(.~ dataset)
#   
#   ggsave(paste("output/species_richness/", li[i], ".jpg", sep = ""), height = 6.5, width=8)
#   
# }
