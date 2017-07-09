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

plot(cand)
plot(vsalt, add = TRUE, col = "red")

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

# calculate area
area(cand)
crs(cand)
area(candbuff)
crs(candbuff)

crs(test)
sum(area(test))

# project to xxx before calculating area
# make sure to have lulc_AG layer loaded from the agbuffer file
testA <- spTransform(test, crs(lulc_AG))
crs(testA)
area(testA)
area(test) # these are different
sum(area(testA))/4046.86 # acres

# Now apply to all pairs of candidate and validated data
cfiles <- list.files("../results/candarea/")

# create a vector the length of cfiles
vsaltarea <- vector("numeric", length(cfiles))
names(vsaltarea) <- cfiles

cropsalt <- function(cand, vsalt, filename){
  candbuff <- gBuffer(cand, byid = TRUE, width = 0)
  vsaltbuff <- gBuffer(vsalt, byid=TRUE, width=0)
  
  cropsalt <- intersect(candbuff, vsaltbuff)
  cropsaltA <- spTransform(cropsalt, crs(lulc_AG))
  # write google earth file
  cropsaltAGE <- spTransform(cropsaltA, CRS("+proj=longlat +datum=WGS84"))
  # write file in results folder
  writeOGR(cropsaltAGE, paste0("../results/candarea_cropped/",
                filename, ".kml"), filename, "KML")
  # return area
  return(sum(area(cropsaltA))/4046.86) # acres)
}

# testing function on first set of polygons
vsaltarea[1] <- cropsalt(cand = readOGR(paste0("../results/candarea/", cfiles[1])),
         vsalt = readOGR(paste0("../data/gabe/", gfiles[1])),
         filename = substr(cfiles[1], 1, 8))

##### MAIN RUNNING OF THE FUNCTION HERE ###
# running function over all 15 polygons
for(i in 1:length(cfiles)){
  vsaltarea[i] <- cropsalt(cand = readOGR(paste0("../results/candarea/", cfiles[i])),
                           vsalt = readOGR(paste0("../data/gabe/", gfiles[i])),
                           filename = substr(cfiles[i], 1, 8))
  
}

for(i in 3:14){
  vsaltarea[i] <- cropsalt(cand = readOGR(paste0("../results/candarea/", cfiles[i])),
                           vsalt = readOGR(paste0("../data/gabe/", gfiles[i])),
                           filename = substr(cfiles[i], 1, 8))
  
}
