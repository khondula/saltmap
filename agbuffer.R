# crop somerset county land use data to ag
# and add a 200m buffer

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
ag200 <- SpatialPolygonsDataFrame(ag200, as.data.frame(ag200))
ag200 <- as(ag200, "SpatialPolygonsDataFrame")
writeOGR(ag200, dsn = ".", "ag200", driver = "ESRI Shapefile")

# also write to google earth
ag200GE <- spTransform(ag200, CRS("+proj=longlat +datum=WGS84"))
writeOGR(ag200GE, "ag200.kml", "ag200", "KML")
