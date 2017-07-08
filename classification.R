library(raster)
library(randomForest)
library(cluster)
library(RStoolbox)
library(sp)
library(rgdal)
library(leaflet)
library(dplyr)
library(rasterVis)

swi <- brick("../data/swi2/NAIP2013/swi2.tif")

# swi <- raster("../data/swi2/NAIP2013/swi2.tif")

plotRGB(swi)
ggRGB(swi)
salt2 <- drawPoly(sp = FALSE)

raster::select(swi)

zoom(swi)

salt <- raster::select(swi, use = "pol", draw = TRUE, col = "cyan")
plotRGB(salt, add = TRUE)

str(swi)
par(mfrow = c(1,1))

plotRGB(swi)
plotRGB(swi)
plot(swi_mask, col = "red", add = TRUE, legend = FALSE)

nr <- getValues(swi)
nr.km <- kmeans(na.omit(nr),
                centers = 10,
                iter.max = 500, 
                nstart = 3,
                algorithm = "Lloyd")
knr <- swi
knr[] <- nr.km$cluster
plot(knr, main = "Unsupervised classification")

findswi <- function(x){
  unC <- unsuperClass(swi, nSamples = 100, nClasses = x, nStarts = 5)
  colors <- rainbow(x)
  plot(unC$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)
}
findswi(7)
findswi(8)

# unC <- unsuperClass(swi, nSamples = 100, nClasses = 7, nStarts = 5)
# colors <- rainbow(7)
# plot(unC$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)


plot(1:7, rep(1,7), col = colors, pch = 17, cex = 10)
swi_mask <- mask(unC$map, unC$map == 7, maskvalue = FALSE)

unC <- unsuperClass(swi, nSamples = 100, nClasses = 10, nStarts = 5)
colors <- rainbow(10)
plot(unC$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)

plot(1:10, rep(1,10), col = rainbow(10), pch = 17, cex = 5)
swi_mask10 <- mask(unC$map, unC$map == 2, maskvalue = FALSE)
par(mfrow = c(1,2))
plotRGB(swi)
plotRGB(swi)
plot(swi_mask10, col = "red", add = TRUE, legend = FALSE)

sum(swi_mask[], na.rm = TRUE)

swi_maskll <- projectRaster(swi_mask, crs="+proj=longlat +ellps=WGS84 +datum=WGS84")
swi_area <- area(swi_maskll, na.rm = TRUE)
plot(swi_area)
swi_area <- swi_area[!is.na(swi_area)]
length(swi_area)*median(swi_area)
# 0.02732089 km2
# 38197.06 m2
swi_poly <- rasterToPolygons(swi_mask)
plot(swi_poly)
library(rgeos)
gArea(swi_poly)

leaflet(swi_mask) %>% addProviderTiles("Esri.WorldImagery") %>% 
  addRasterImage(x = swi_mask, opacity = 1, colors = "red", group = "class7") %>%
  addLayersControl(overlayGroups = c("class7"), 
                   options = layersControlOptions(collapsed = FALSE))


plot(swi_mask)


unC$map

cir <- brick("../data/greenhead_farm/EasternShoreCIR2016/greenhead_farm.jpg")
plot(cir)
raster::plotRGB(cir)

img <- brick("../data/greenhead_farm/EasternShore2016/greenhead_farm.jpg")
plot(img)
raster::plotRGB(img)

naip <- brick("../data/greenhead_farm/NAIP2015/greenhead_farm.jpg")
plot(naip)
raster::plotRGB(naip)

naip2 <- brick("../data/NAIP2015/greenhead2.jpg")
raster::plotRGB(naip2)

alm <- brick("../data/almodinton/NAIP2015/almodinton_3.jpg")
raster::plotRGB(alm)

set.seed(25)
unC <- unsuperClass(alm, nSamples = 100, nClasses = 6, nStarts = 5)
unC

colors <- rainbow(6)
plot(unC$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)

set.seed(25)
unC <- unsuperClass(cir, nSamples = 100, nClasses = 10, nStarts = 5)
unC

colors <- rainbow(10)
plot(unC$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)

# import someserset county land use data

shp <- "../data/Some_2010LULC/"
lulc <- readOGR(dsn = shp,
                    layer = "Some_2010LULC",
                    stringsAsFactors = FALSE)

lulcT <- spTransform(lulc, CRS("+proj=longlat +datum=WGS84 +no_defs"))
table(lulcT@data$LU_CODE)

lulc_AG <- lulcT[lulcT$LU_CODE %in% c(21, 22, 23, 25, 241, 242, 20),]
plot(lulc_AG)
# guide to LU_CODE
# http://geodata.md.gov/imap/rest/services/PlanningCadastre/MD_LandUseLandCover/MapServer/1
# Ag is 21, 22, 23, 25, 241, 242, 20

leaflet(lulc_AG) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons()
