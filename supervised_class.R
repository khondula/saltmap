library(rgdal)
library(leaflet)
library(e1071)
library(plotKML)

list.files("/nfs/khondula-data/Delmarva/SWI/data/")

swi_train <- readOGR("/nfs/khondula-data/Delmarva/SWI/data/swi_training.kml",
                     layer = "swi_training")


swi <- brick("../data/swi2/NAIP2013/swi2.tif")
swi <- raster("../data/swi2/NAIP2013/swi2.tif")
plotRGB(swi)

# might be good to add different classes
# eg. non swi areas
# to training data

swi_train <- spTransform(swi_train, crs(swi))
swi_train <- gBuffer(swi_train, byid=TRUE, width=0)
swi_train <- raster::crop(swi_train, extent(swi))

plotRGB(swi)
# colors <- c("yellow", "green", "deeppink", "red")
plot(swi_train, add = TRUE, col = colors[swi_train$Name])
plot(swi_train)

leaflet(swi_train) %>% 
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(fillOpacity = 0, color = "red", opacity = 1) %>% 
  addRasterImage(swi)

### unsupervised 
### classification

set.seed(25)
unC <- unsuperClass(swi, nSamples = 100, nClasses = 10, nStarts = 5)
unC
colors <- rainbow(10)
plot(unC$map, col = colors, axes = FALSE, box = FALSE)
raster::select(unC$map)
# 12 classes
set.seed(25)
unC12 <- unsuperClass(swi, nSamples = 100, nClasses = 12, nStarts = 5)
unC
colors <- rainbow(12)
plot(unC12$map, col = colors, axes = FALSE, box = FALSE)
salt_class <- unC12$map[116440]
swi_mask2 <- mask(unC12$map, unC$map == salt_class, maskvalue = FALSE)

# zoom(unC$map)
# raster::click(unC$map, cell = TRUE)
# which class is cell 116440
salt_class <- unC$map[116440]

# mask only class of that pixel
swi_mask <- mask(unC$map, unC$map == salt_class, maskvalue = FALSE)
par(mfrow = c(1,2))
plot(swi)
plotRGB(swi)

plot(swi_mask, col = "red", add = TRUE, legend = FALSE)
lulc_AG <- spTransform(lulc_AG, crs(swi_mask))
plot(lulc_AG, col = "yellow", add = TRUE, fill = FALSE)
plot(lulc_AG)

swi_mask_polygon <- rasterToPolygons(swi_mask)
swi_mask_polygon2 <- rasterToPolygons(swi_mask, dissolve = TRUE)
swi_mask_polygon3 <- rasterToPolygons(swi_mask, dissolve = TRUE)
plot(swi_mask_polygon2)

swi_mask_polygon2 <- rasterToPolygons(swi_mask, dissolve = TRUE)
swi_mask_polygonGE <- spTransform(swi_mask_polygon2, CRS("+proj=longlat +datum=WGS84"))

crs(swi_mask_polygon)
area(swi_mask_polygon2)/1000000
area(swi_mask_polygon3)/1000000

aglandGE <- spTransform(lulc_AG, CRS("+proj=longlat +datum=WGS84"))

writeOGR(aglandGE, "aglandGE.kml", "aglandGE", "KML")

writeOGR(swi_mask_polygonGE, "swi_mask.kml", "swi_mask", "KML")
# writeOGR(swi_mask_polygon, "swi_mask.kml", layer = "swi_mask_polygon")

### supervised
### classification
sc <- superClass(swi, trainData = swi_train,
                 responseCol = "Name",
                 model = "rf")
sc

par(mfrow=c(1,2))
plot(sc$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)
legend(1,1, legend = levels(swi_train$Name), fill = colors , title = "Classes", 
       horiz = TRUE,  bty = "n")




