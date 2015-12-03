library(sp)
library(rgdal)
library(maptools)

setwd("H:/Tweets_SR/Data")

proj <- CRS("+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0")
rawFol <- "../Data/Spatial/TractsRaw"
outFol <- "C:/Users/Eric/Desktop/Tracts"

StateFIPS <- list.files(path=rawFol, pattern="*_tract10.shp$")

tracts <- readOGR(rawFol,layer="tl_2010_01_tract10")
tracts <- spChFIDs(tracts,paste("map1",sapply(slot(tracts,"polygons"),slot,"ID"),sep="_"))

for(i in 2:length(StateFIPS)) {
  layer = substr(StateFIPS[i],1,18)
  tracts2 <- readOGR(rawFol,layer)
  tracts2 <- spChFIDs(tracts2,paste("map",toString(i),sapply(slot(tracts2,"polygons"),slot,"ID"),sep="_"))
  tracts <- spRbind(tracts,tracts2)  
}

tracts@data <- tracts@data[,-c(5:length(tracts@data))]

writeOGR(tracts, outFol, "Tracts2010", driver="ESRI Shapefile", overwrite_layer=TRUE)
