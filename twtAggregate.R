library(sp)
library(rgdal)
library(GISTools)
library(dplyr)

setwd("H:/Tweets_SR/Data")

proj <- CRS("+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0")
outFol <- "../Data/Spatial"

coords2012 <- "../Data/Tabular/tweets2012.csv"
out2012 <- "tweets2012"
# coords2015 <- "../Data/Tabular/tweets2015.csv"
# out2015 <- "tweets2015"

counties <- readOGR("../Data/Spatial","USCounties2010")
tracts <- readOGR("C:/Users/emhun/Desktop/Tweets_GWR/Data/Spatial","TractsPop")
counties <- counties[,-c(1:3,6:17)]
# tracts <- tracts[,-c(1:3,6:17)]
countiesPop <- read.csv("../Data/Tabular/pop2012.csv", header = TRUE)

for(i in 1:length(countiesPop$geoid)) {
  if (nchar(countiesPop$geoid[i]) < max(nchar(countiesPop$geoid))) {
    countiesPop$geoid[i] <- paste("0",toString(countiesPop$geoid[i]),sep="")
  }
}

counties@data <- left_join(counties@data,countiesPop,by=c("GEOID10" = "geoid"))

coord2Pt <- function(coordsCSV, outFol, outName, proj, duplicate.del) {

  coords <- read.csv(coordsCSV, header = TRUE)
  coords <- coords[,1:2]
  
  if (duplicate.del == TRUE) {
    lngDup <- duplicated(coords[,1])
    latDup <- duplicated(coords[,2])
    lngLatList <- list(lngDup,latDup)
    lngLatList <- Reduce("&",lngLatList)
    coords <- coords[!lngLatList,1:2]
  }
  
  coordinates(coords) <- c("longitude","latitude")
  
  coords <- SpatialPointsDataFrame(coords, data.frame(rep(1,length(coords))))
  
  proj4string(coords) <- proj
  
  writeOGR(coords, outFol, outName, driver="ESRI Shapefile", overwrite_layer=TRUE)
  
  return(coords)
  
}

tweets <- coord2Pt(coords2012,outFol,out2012,proj,duplicate.del=TRUE)
counties$tweets <- sapply(over(counties,as(tweets,"SpatialPoints"),returnList=TRUE), length)

counties@data$poplog <- log10(counties$pop+1)
counties@data$tweetsLog <- log10(counties$tweets+1)

tracts$tweets <- sapply(over(tracts,as(tweets,"SpatialPoints"),returnList=TRUE), length)

tracts@data$poplog <- log10(tracts$pop+1)
tracts@data$tweetsLog <- log10(tracts$tweets+1)

writeOGR(counties, "../Data/Spatial", "countiesTwt", driver="ESRI Shapefile", overwrite_layer=TRUE)
writeOGR(tracts, "../Data/Spatial", "tractsTwt", driver="ESRI Shapefile", overwrite_layer=TRUE)