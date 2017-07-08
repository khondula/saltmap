# cell in each raster that is swi

swicells <- t(data.frame(
  agswi_12 = NA,
  agswi_13 = NA,
  agswi_19 = NA,
  agswi_26 = NA,
  agswi_27 = NA,
  agswi_28 = NA,
  agswi_29 = NA,
  agswi_30 = NA,
  agswi_31 = NA,
  agswi_32 = 9096257,
  agswi_33 = NA, 
  agswi_34 = NA,
  agswi_35 = 5428401,
  agswi_36 = 7618795,
  agswi_37 = 17785943,
  agswi_38 = NA,
  agswi_39 = 1032202,
  agswi_40 = 7909355,
  agswi_41 = NA,
  agswi_42 = NA,
  agswi_43 = NA,
  agswi_44 = 8602365,
  agswi_45 = 16526561,
  agswi_46 = 6129555,
  agswi_47 = NA,
  agswi_48 = NA,
  agswi_49 = 16623157,
  agswi_50 = NA,
  agswi_51 = 9414883,
  agswi_52 = 5054074,
  agswi_53 = NA,
  agswi_54 = 18920015,
  agswi_55 = 8381131,
  agswi_56 = 1607799,
  agswi_57 = NA,
  agswi_58 = NA, # lots of chicken houses
  agswi_59 = NA,
  agswi_60 = NA,
  agswi_61 = NA,
  agswi_62 = NA,
  agswi_63 = 18523399,
  agswi_64 = 3990024,
  agswi_66 = NA,
  agswi_67 = NA,
  agswi_68 = NA,
  agswi_69 = NA,
  agswi_70 = NA,
  agswi_8 = NA
))

# get lat long coords from these cells

swicells <- as.data.frame(swicells)
names(swicells) <- "cellID"
head(swicells)
swicells$file_no <- 1:nrow(swicells)

swicells2 <- swicells[complete.cases(swicells),]

pts <- sapply(1:nrow(swicells2), function(x) 
  xyFromCell(brick(file.path(path, files[swicells2[x,"file_no"]])), 
             cell = swicells2[x, "cellID"], spatial = TRUE))

pts <- lapply(pts, function(x) spTransform(x, CRS("+init=epsg:4326")))
allpts <- do.call("rbind", pts) 

allpts <- SpatialPointsDataFrame(allpts@coords, data = swicells2, proj4string = crs(allpts))

writeOGR(allpts, paste0("../results/", "swicells", ".kml"), swicells, "KML")


allpts@data
write.csv(allpts@coords, "swicells_coords.csv")
write.csv(swicells, "swicells.csv")
