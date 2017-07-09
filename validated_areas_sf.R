
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
test_df <- raster::as.data.frame(test)

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

vsaltarea[2] <- runCropSalt(2) # 
vsaltarea[3] <- runCropSalt(3) # 
vsaltarea[4] <- runCropSalt(4) #  
vsaltarea[5] <- runCropSalt(5) #  
vsaltarea[6] <- runCropSalt(6) # this froze up earlier?  
vsaltarea[6] <- runCropSalt(6)   
vsaltarea[7] <- runCropSalt(7)  
vsaltarea[8] <- runCropSalt(8)  
vsaltarea[9] <- runCropSalt(9)
# vsaltarea[10] <- runCropSalt(10)
vsaltarea[11] <- runCropSalt(11)
vsaltarea[12] <- runCropSalt(12)
vsaltarea[13] <- runCropSalt(13)
vsaltarea[14] <- runCropSalt(14)
