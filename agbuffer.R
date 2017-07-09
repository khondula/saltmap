# crop somerset county land use data to ag
# and add a 200m buffer

library(raster)
library(leaflet)
library(rgdal)
library(rgeos)
library(RStoolbox)

# use to download imagery data

shp <- "../data/Some_2010LULC/"
lulc <- readOGR(dsn = shp,
                layer = "Some_2010LULC",
                stringsAsFactors = FALSE)

# # spatial transformation for plotting in leaflet
# lulcT <- spTransform(lulc, CRS("+proj=longlat +datum=WGS84 +no_defs"))
# table(lulcT@data$LU_CODE)

lulc_AG <- lulc[lulc$LU_CODE %in% c(21, 22, 23, 25, 241, 242, 20),]

plot(lulc_AG)
crs(lulc_AG)

ag200 <- gBuffer(lulc_AG, width=200)
ag200 <- as(ag200, "SpatialPolygonsDataFrame")

# writeOGR(ag200, dsn = ".", "ag200", driver = "ESRI Shapefile")

# also write to google earth
ag200GE <- spTransform(ag200, CRS("+proj=longlat +datum=WGS84"))
# writeOGR(ag200GE, "ag200.kml", "ag200", "KML")

# calculate areas 

# just ag land
# units is m
sum(area(lulc_AG))/10000 # hecatres
sum(area(lulc_AG))/1e+6 # sq km
sum(area(lulc_AG))/4046.86 # acres
# MD planning website 
# https://planning.maryland.gov/PDF/OurWork/LandUse/County/Somerset.pdf
# ag land use in 2010 is listed as 49,693 acres

# ag land buffered to 200m
sum(area(ag200))/4046.86 # acres
# buffered area is over twice that size at 112,229.2 acres

# how much of that area is in the inspected extent
list.files(path)

img <- brick(file.path(path, files[10]))
img <- projectExtent(img, crs(lulc_AG))
plot(extent(img), add = TRUE, col = "blue")

extentareas <- vector("numeric", 13)
# 32
img <- brick(file.path(path, files[10]))
img <- projectExtent(img, crs(lulc_AG))
e32 <- crop(lulc_AG, extent(img))
extentareas[1] <- sum(area(e32))/4046.86 # acres
# 35
img <- brick(file.path(path, files[13]))
img <- projectExtent(img, crs(lulc_AG))
e35 <- crop(lulc_AG, extent(img))
extentareas[2] <- sum(area(e35))/4046.86 # acres
# 36
img <- brick(file.path(path, files[14]))
img <- projectExtent(img, crs(lulc_AG))
e36 <- crop(lulc_AG, extent(img))
extentareas[3] <- sum(area(e36))/4046.86 # acres
# 39
img <- brick(file.path(path, files[17]))
img <- projectExtent(img, crs(lulc_AG))
e39 <- crop(lulc_AG, extent(img))
extentareas[4] <- sum(area(e39))/4046.86 # acres
# 40
img <- brick(file.path(path, files[18]))
img <- projectExtent(img, crs(lulc_AG))
e40 <- crop(lulc_AG, extent(img))
extentareas[5] <- sum(area(e40))/4046.86 # acres
# 44
img <- brick(file.path(path, files[22]))
img <- projectExtent(img, crs(lulc_AG))
e44 <- crop(lulc_AG, extent(img))
extentareas[6] <- sum(area(e44))/4046.86 # acres
# 45
img <- brick(file.path(path, files[23]))
img <- projectExtent(img, crs(lulc_AG))
e45 <- crop(lulc_AG, extent(img))
extentareas[7] <- sum(area(e45))/4046.86 # acres
# 49
img <- brick(file.path(path, files[27]))
img <- projectExtent(img, crs(lulc_AG))
e49 <- crop(lulc_AG, extent(img))
extentareas[8] <- sum(area(e49))/4046.86 # acres
# 51
img <- brick(file.path(path, files[29]))
img <- projectExtent(img, crs(lulc_AG))
e51 <- crop(lulc_AG, extent(img))
extentareas[9] <- sum(area(e51))/4046.86 # acres
# 52
img <- brick(file.path(path, files[30]))
img <- projectExtent(img, crs(lulc_AG))
e52 <- crop(lulc_AG, extent(img))
extentareas[10] <- sum(area(e52))/4046.86 # acres
# 54
img <- brick(file.path(path, files[32]))
img <- projectExtent(img, crs(lulc_AG))
e54 <- crop(lulc_AG, extent(img))
extentareas[11] <- sum(area(e54))/4046.86 # acres
# 55
img <- brick(file.path(path, files[33]))
img <- projectExtent(img, crs(lulc_AG))
e55 <- crop(lulc_AG, extent(img))
extentareas[12] <- sum(area(e55))/4046.86 # acres
# 56
img <- brick(file.path(path, files[34]))
img <- projectExtent(img, crs(lulc_AG))
e56 <- crop(lulc_AG, extent(img))
extentareas[13] <- sum(area(e56))/4046.86 # acres

sum(extentareas)
