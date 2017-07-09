# use gabe's polygons
# to crop the candidate SWI areas
# to validated SWI areas

library(sp)
library(rgdal)
library(rgeos)
library(leaflet)

# load polygons of candidate areas
cand <- readOGR("../results/agswi_32.kml")

plot(cand)

leaflet(cand) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(color = "red")

# load gabe's polygons

gfiles <- list.files("../data/gabe/")

vsalt <- readOGR(paste0("../data/gabe/", gfiles[1]))

# 0 width buffer prevents topology errors
# warning that object is not projected though
# GEOS expects planar coordinates
candbuff <- gBuffer(cand, byid = TRUE, width = 0)
vsaltbuff <- gBuffer(vsalt, byid=TRUE, width=0)

leaflet(vsaltbuff) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(color = "yellow")

# crop candidate areas to those within other polygon boundaries

# identify cand polygons that intersect vsalt polygons
# is each cand polygon inside any of the polygons from vsalt
test <- intersect(candbuff, vsaltbuff)

# looks like it worked!
leaflet(test) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(color = "red") %>%
  addPolygons(data = candbuff, color = "blue", group = "cand") %>%
  addPolygons(data = vsaltbuff, color = "yellow", group = "validated") %>%
  addLayersControl(overlayGroups = c("validated", "cand"))


plot(cand)
plot(vsalt, add = TRUE, col = "red")
