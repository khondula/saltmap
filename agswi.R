###################################################
# Image classification for salt water intrusion
# lower delmarva peninsula
# Kelly Hondula
# khondula@sesync.org
# Last updated 25-June-2017
###################################################

library(raster)
library(leaflet)
library(rgdal)
library(rgeos)
library(RStoolbox)

# NAIP 2015 downloaded from MD Express Zip website

path <- "/nfs/khondula-data/Delmarva/SWI/data/agswi\ (1)/NAIP2015"
files <- list.files(path)


################################################
# read in tif of the agswi imagery data 
################################################



img <- brick(file.path(path, files[13]))

# plot, zoom, click to identify a cell with SWI
par(mfrow=c(1,1))
plotRGB(img)
raster::zoom(img)
raster::click(img, cell = TRUE)

# go to express zip website to zoom in on true color image
# http://imagery.geodata.md.gov:8080/ExpressZip
# look at where the area is by plotting raster with the agland boundary
# or on leaflet
# or naip2015 imagery 

pdf(file= "tilelocations2.pdf")
plot(ag2)
for(i in 1:length(files)){
  img <- brick(file.path(path, files[i]))
  plot(extent(img), add = TRUE)
  graphics::text(x = mean(bbox(img)[1,]),
                 y = mean(bbox(img)[2,]),
                 as.character(substr(files[i], 7, nchar(files[i])-4)), col = "blue", font = 2)
}
dev.off()
# bbox(img)
# plotRGB(img, add=TRUE)

leaflet(ag200GE) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(fillColor = "white",fillOpacity = 0) %>%
  addRasterImage(r32, maxBytes = 15e6)

################################################
################################################

# define function that classifies input raster
# using the unsuperClass function
# create swi mask output as kml file
# inputs: raster image, nclasses, ID of swi pixel, filename to save kml
# outputs: saves a kml file in results folder

unC <- unsuperClass(img, nSamples = 100, nClasses = 12, nStarts = 5)
colors <- rainbow(12)
plot(unC$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)


findswi <- function(inputimage, nClasses = 12, saltcellID = 8611994, filename = "swi"){
  # makes results exactly reproducible
  set.seed(25)
  # main function for classification from RStoolbox package
  unC12 <- unsuperClass(inputimage, nSamples = 100, nClasses = nClasses, nStarts = 5)
  # identify class of swi input cell
  salt_class <- unC12$map[saltcellID] 
  # use set everything else to FALSE for mask
  swi_mask <- mask(unC12$map, unC12$map == salt_class, maskvalue = FALSE)
  # convert raster to one polygon layer
  swi_mask_polygon <- rasterToPolygons(swi_mask, dissolve = TRUE)
  # transform for saving to google earth kml 
  swi_mask_polygonGE <- spTransform(swi_mask_polygon, CRS("+proj=longlat +datum=WGS84"))
  # write file in results folder
  writeOGR(swi_mask_polygonGE, paste0("../results/",
      filename, ".kml"), filename, "KML")
}

# function for saving side by side jpegs of image classification
findswi_image <- function(inputimage, nClasses = 12, 
                          saltcellID = 8611994, filename = "swi"){
  # makes results exactly reproducible
  set.seed(25)
  # main function for classification from RStoolbox package
  unC12 <- unsuperClass(inputimage, nSamples = 100, nClasses = nClasses, nStarts = 5)
  # identify class of swi input cell
  salt_class <- unC12$map[saltcellID] 
  # use set everything else to FALSE for mask
  swi_mask <- mask(unC12$map, unC12$map == salt_class, maskvalue = FALSE)
  
  pdf(paste0("../results/", filename, ".pdf"))
  par(mfrow=c(1,2))
  plotRGB(inputimage)
  plotRGB(inputimage)
  plot(swi_mask, col = "red", add = TRUE, legend = FALSE)
  dev.off()

}

################################################
# test Applying function 
################################################

findswi(inputimage = r44, 
        nClasses = 12,  
        saltcellID = 8602365, 
        filename = "swi_fxntest")

findswi(inputimage = brick(file.path(path, files[10])), 
        nClasses = 12,  
        saltcellID = swicells[i,1], 
        filename = substr(files[10], 1, nchar(files[10])-4))


################################################
# MAIN PART IS HERE
# loop over each tif
# this will take a while
################################################

for(i in 1:nrow(swicells)){
  if(!is.na(swicells[i,1])){
  findswi(inputimage = brick(file.path(path, files[i])), 
          nClasses = 12,  
          saltcellID = swicells[i,1], 
          filename = substr(files[i], 1, nchar(files[i])-4))}
}

for(i in 1:nrow(swicells)){
  if(!is.na(swicells[i,1])){
    findswi_image(inputimage = brick(file.path(path, files[i])), 
            nClasses = 12,  
            saltcellID = swicells[i,1], 
            filename = substr(files[i], 1, nchar(files[i])-4))}
}

findswi_image(inputimage = brick(file.path(path, files[10])),
              nClasses = 12,
              saltcellID = swicells[10,1],
              filename = substr(files[10], 1, nchar(files[10])-4))
################################################
################################################


# plotting results of classification
# colors <- rainbow(12)
# plot(unC12$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)
# plot image and save side by side images
# # save as jpeg?
# par(mfrow=c(1,2))
# plotRGB(r44)
# plotRGB(r44)
# plot(swi_mask, col = "red", add = TRUE, legend = FALSE)



