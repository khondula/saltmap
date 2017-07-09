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