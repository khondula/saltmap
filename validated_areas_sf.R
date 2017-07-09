
library(sp)
library(rgdal)
library(rgeos)
library(leaflet)
library(raster)


cfiles <- list.files("../results/candarea/")
gfiles <- list.files("../data/gabe/")

cand <- readOGR(paste0("../results/candarea/", cfiles[1]))
vsalt <- readOGR(paste0("../data/gabe/", gfiles[1]))

candbuff <- gBuffer(cand, byid = TRUE, width = 0)
vsaltbuff <- gBuffer(vsalt, byid=TRUE, width=0)

cand3 <- readOGR(paste0("../results/candarea/", cfiles[3]))
vsalt3 <- readOGR(paste0("../data/gabe/", gfiles[3]))

candbuff <- gBuffer(cand3, byid = TRUE, width = 0)
vsaltbuff <- gBuffer(vsalt3, byid=TRUE, width=0)

cand4 <- readOGR(paste0("../results/candarea/", cfiles[4]))
vsalt4 <- readOGR(paste0("../data/gabe/", gfiles[4]))

candbuff <- gBuffer(cand4, byid = TRUE, width = 0)
vsaltbuff <- gBuffer(vsalt4, byid=TRUE, width=0)

test <- raster::intersect(candbuff, vsaltbuff)
plot(cand)
plot(vsaltbuff, col = "red", add = TRUE)

test2 <- gIntersection(candbuff, vsaltbuff, byid = TRUE, drop_lower_td = TRUE)

candbuff
vsaltbuff

# looks like it worked!
leaflet(test2) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(color = "red") %>%
  addPolygons(data = candbuff, color = "blue", group = "cand") %>%
  addPolygons(data = vsaltbuff, color = "yellow", group = "validated") %>%
  addLayersControl(overlayGroups = c("validated", "cand"))


# test using sf
install.packages("sf")
library(sf)

cb <- st_as_sfc(candbuff)
vb <- st_as_sfc(vsaltbuff)

plot(candbuff)
plot(vsaltbuff, col = "yellow", add = TRUE)

plot(st_intersection(st_union(cb),st_union(vb)), col = 'red')
testsf <- st_intersection(st_union(cb),st_union(vb))

test <- as(testsf, "Spatial")

leaflet(test) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(color = "red") 

cropsaltA <- spTransform(test, crs(lulc_AG))
# return area
sum(area(cropsaltA))/4046.86 # acres

# define crop salt function using sf

cropsalt <- function(cand, vsalt){
  candbuff <- gBuffer(cand, byid = TRUE, width = 0)
  vsaltbuff <- gBuffer(vsalt, byid=TRUE, width=0)
  
  cb <- st_as_sfc(candbuff)
  vb <- st_as_sfc(vsaltbuff)
  saltvalsf <- st_intersection(st_union(cb),st_union(vb))
  
  saltval <- as(saltvalsf, "Spatial")
  
  saltvalA <- spTransform(saltval, crs(lulc_AG))
  # write google earth file
  # saltvalA_GE <- spTransform(saltvalA, CRS("+proj=longlat +datum=WGS84"))
  # # write file in results folder
  # writeOGR(saltvalA_GE, paste0("../results/candarea_cropped/",
  #                              filename, ".kml"), filename, "KML")
  # return area
  return(sum(area(saltvalA))/4046.86) # acres)
}

runCropSalt <- function(x){
  vsaltarea <- cropsalt(cand = readOGR(paste0("../results/candarea/", cfiles[x])),
                        vsalt = readOGR(paste0("../data/gabe/", gfiles[x])))
  return(vsaltarea)
}

vsaltarea["agswi_39.kml"] <- 
  cropsalt(cand = readOGR("../results/candarea/agswi_39.kml"), 
           vsalt = readOGR("../data/gabemod/agswi_39_Polygons.kmz"))

vsaltarea["agswi_45.kml"] <- 
  cropsalt(cand = readOGR("../results/candarea/agswi_45.kml"), 
           vsalt = readOGR("../data/gabemod/agswi_45_Polygons.kmz"))

vsaltarea["agswi_36.kml"] <- 
  cropsalt(cand = readOGR("../results/candarea/agswi_36.kml"), 
           vsalt = readOGR("../data/gabemod/agswi_36_Polygons.kmz"))

# no polygon areas identified
# vsaltarea["agswi_46.kml"] <- 
#   cropsalt(cand = readOGR("../results/candarea/agswi_46.kml"), 
#            vsalt = readOGR("../data/gabemod/agswi_46_Polygons.kmz"))

vsaltarea["agswi_49.kml"] <- 
  cropsalt(cand = readOGR("../results/candarea/agswi_49.kml"), 
           vsalt = readOGR("../data/gabemod/agswi_49_Polygons.kmz"))

vsaltarea["agswi_52.kml"] <- 
  cropsalt(cand = readOGR("../results/candarea/agswi_52.kml"), 
           vsalt = readOGR("../data/gabemod/agswi_52_Polygons.kmz"))

vsaltarea["agswi_55.kml"] <- 
  cropsalt(cand = readOGR("../results/candarea/agswi_55.kml"), 
           vsalt = readOGR("../data/gabemod/agswi_55_Polygons.kmz"))

vsaltarea["agswi_56.kml"] <- 
  cropsalt(cand = readOGR("../results/candarea/agswi_56.kml"), 
           vsalt = readOGR("../data/gabemod/agswi_56_Polygons.kmz"))

vsaltarea['agswi_46.kml'] <- 0

vsaltarea[2] <- runCropSalt(2) # 
vsaltarea[3] <- runCropSalt(3) # 
vsaltarea[4] <- runCropSalt(4) #  
vsaltarea[5] <- runCropSalt(5) #  no gabe areas?
# vsaltarea[6] <- runCropSalt(6)  # no gabe polygons 
vsaltarea[7] <- runCropSalt(7)  
vsaltarea[8] <- runCropSalt(8)  
vsaltarea[9] <- runCropSalt(9)
# vsaltarea[10] <- runCropSalt(10) no polygons
vsaltarea[11] <- runCropSalt(11)
vsaltarea[12] <- runCropSalt(12)
vsaltarea[13] <- runCropSalt(13)
vsaltarea[14] <- runCropSalt(14)

sum(vsaltarea)

write.csv(as.data.frame(vsaltarea), "vsaltarea.csv")
