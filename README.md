# saltmap

Mapping salt water intrusion on the lower eastern shore of maryland

* `agbuffer.R` - takes the 2010 Somerset County land use data to identify agricultural areas and create a layer that is agricultural land buffered to 200m. Total area of ag land is 49,693 acres and buffered area is 112,229 acres.
* `swicells.R` - get coordinates of manually identified cells in images as salt water intrusion.
* `agswi.R` - mapping functions used for identification of pixels and unsupervised image classification on NAIP 2015 imagery. creates the KML files of candidate salt water intrusion areas.

__Out of 112,229 acres, how much area was included in the tiles used for unsupervised classification?__

__Out of that area, how much was classified into the candidate salt water intrusion areas?__

* `validated_areas.R` - uses polygons created from visual inspection of candidate areas to crop candidate areas to validated areas with the `intersect()` function in rgeos.

__What is the total area of validated polygons?__

* supervised classification with training data, estimate total area with uncertainty using confusion matrix




