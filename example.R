
#loading the data
vancouver <- readRDS("./vancouver.rds")

#visualizing in ggplot
library(ggplot2)
ggplot(vancouver) + geom_sf(aes(fill = median_hh_income), colour = "grey") +
  scale_fill_viridis_c("Median HH Income", labels = scales::dollar) + theme_minimal() +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()) + 
  coord_sf(datum=NA) +
  labs(title = "Median Household Income", subtitle = "Vancouver Census Subdivisions, 2016 Census")

#visualizing in leaflet
library(leaflet)
leaflet(vancouver) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons()

bins <- c(0, 30000,40000, 50000,60000, 70000,80000, 90000,100000, 110000, Inf)
pal <- colorBin("RdYlBu", domain = vancouver$v_CA16_2397, bins = bins)
leaflet(vancouver) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(fillColor = ~pal(median_hh_income),
              color = "white",
              weight = 1,
              opacity = 1,
              fillOpacity = 0.65) %>% 
  addLegend("topright", pal = pal, values = ~median_hh_income,
            title = "Median Household Income (2016)",
            labFormat = labelFormat(prefix = "$"),
            opacity = 1)