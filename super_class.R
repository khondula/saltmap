# supervised classification
# using gabe's polygons
library(RStoolbox)
library(sf)
library(raster)
library(leaflet)
library(maptools)
### supervised
### classification

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
# difference for non-SWI white areas
saltyesSF <- st_as_sf(saltyes)
plot(saltyesSF)
plot(saltyes)
# find classified areas that are not validated
saltno <- st_difference(st_union(cb),st_union(saltyes))
# visual inspection
leaflet(saltyesSP) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(color = "red", group = "saltyes") %>%
  addPolygons(data = saltnoSP, color = "blue", group = "saltno") %>%
  addLayersControl(overlayGroups = c("saltyes", "saltno"))

##############################
# merge together using sf
head(saltno@data)
class(saltno)
class(saltyes)

saltyes2 <- st_cast(saltyes, to ="POLYGON", ids = seq_along(x), group_or_split = TRUE)
saltyesSP <- as(saltyes, "Spatial")
saltyesSP_diss <- disaggregate(saltyesSP)
saltyesSP <- SpatialPolygonsDataFrame(saltyesSP_diss,
                                      data.frame(saltyes2), match.ID = TRUE)

plot(saltyesSP)
class(saltyesSP)
saltyesSP@data$classification <- "SaltWaterIntrusion"

saltno2 <- st_cast(saltno, to = "POLYGON", ids = seq_along(x), group_or_split = TRUE)
saltnoSP <- as(saltno, "Spatial")
saltnoSP_diss <- disaggregate(saltnoSP)
saltnoSP <- SpatialPolygonsDataFrame(saltnoSP_diss, 
                                     data.frame(saltno2), match.ID = FALSE)
saltnoSP@data$classification <- "NotSalt"


# then merge those polygons together
salt_train <- raster::union(saltyesSP, saltnoSP)
saltyesSP@data
slotNames(saltyesSP@polygons[[1]])
saltyesSP@polygons[[1]]@ID
length(saltyesSP@polygons)
length(saltnoSP@polygons)
# change feature IDs to do rbind
saltyesSP2 <- spChFIDs(saltyesSP, paste0(1:length(saltyesSP@polygons),"_salt"))
salt_train2 <- spRbind(saltyesSP2, saltnoSP)
# training data should be validated polygons based on gabes
# use those areas to group polygons into swi areas and not
table(salt_train2@data$classification)
pal <- colorFactor(rainbow(2), salt_train2$classification)

leaflet(salt_train2) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(popup = ~classification, color = ~pal(classification))

?superClass
# raster object to classify
# NAIP 2015 downloaded from MD Express Zip website

# need to add in an OTHER category to training data
# based on all the non-candidate areas



path <- "/nfs/khondula-data/Delmarva/SWI/data/agswi\ (1)/NAIP2015"
files <- list.files(path)
img <- brick(file.path(path, files[10]))
salt_train3 <- spTransform(salt_train2, crs(img))

plot(img)
plot(salt_train3, add = TRUE)

sc <- superClass(img, 
                 trainData = salt_train3,
                 responseCol = "classification",
                 model = "rf", 
                 trainPartition = 0.7)
sc

colors <- rainbow(3)

par(mfrow=c(1,1))
plot(sc$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)

legend(x = "top", legend = unique(salt_train3$classification), fill = colors , title = "Classes", 
       horiz = TRUE,  bty = "n")
