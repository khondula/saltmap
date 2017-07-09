# supervised classification
# using gabe's polygons
library(RStoolbox)

### supervised
### classification

# raster object to classify
img <- brick(file.path(path, files[10]))
swi_train <- readOGR(paste0("../data/gabe/", gfiles[1]))

sc <- superClass(img, trainData = swi_train,
                 responseCol = "Name",
                 model = "rf")
sc

par(mfrow=c(1,2))
plot(sc$map, col = colors, legend = FALSE, axes = FALSE, box = FALSE)
legend(1,1, legend = levels(swi_train$Name), fill = colors , title = "Classes", 
       horiz = TRUE,  bty = "n")