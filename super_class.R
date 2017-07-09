# supervised classification
# using gabe's polygons
library(RStoolbox)
library(sf)
library(raster)
library(leaflet)
### supervised
### classification

# raster object to classify
img <- brick(file.path(path, files[10]))

cfiles <- list.files("../results/candarea/")
gfiles <- list.files("../data/gabe/")
cand <- readOGR(paste0("../results/candarea/", cfiles[1]))
vsalt <- readOGR(paste0("../data/gabe/", gfiles[1]))
candbuff <- gBuffer(cand, byid = TRUE, width = 0)
vsaltbuff <- gBuffer(vsalt, byid=TRUE, width=0)
# make into simple features
cb <- st_as_sf(candbuff)
vb <- st_as_sf(vsaltbuff)
# intersection for SWI validated areas
saltyes <- st_intersection(st_union(cb),st_union(vb))
saltyesSP <- as(saltyes, "Spatial")
saltyesSP <- SpatialPolygonsDataFrame(saltyesSP, data.frame(saltyes), match.ID = FALSE)
saltyes <- disaggregate(saltyesSP)
plot(saltyes)
saltyes@data$classification <- "SaltWaterIntrusion"
# difference for non-SWI white areas
saltyesSF <- st_as_sf(saltyes)
plot(saltyesSF)
saltno <- st_difference(st_union(cb),st_union(saltyesSF))
saltnoSP <- as(saltno, "Spatial")
saltnoSP <- SpatialPolygonsDataFrame(saltnoSP, data.frame(saltno), match.ID = FALSE)
saltno <- disaggregate(saltnoSP)
saltno@data$classification <- "NotSalt"
# visual inspection
leaflet(saltyes) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(color = "red", popup = ~classification) %>%
  addPolygons(data = cand, color = "blue")

# then merge those polygons together



# training data should be validated polygons based on gabes
# use those areas to group polygons into swi areas and not


?superClass

sc <- superClass(img, trainData = swi_train,
                 responseCol = "Name",
                 model = "rf")
sc

par(mfrow=c(1,2))
plot(sc$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)
legend(1,1, legend = levels(swi_train$Name), fill = colors , title = "Classes", 
       horiz = TRUE,  bty = "n")