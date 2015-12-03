library(sp)
library(rgdal)
library(GISTools)
library(dplyr)
library(spgwr)

setwd("C:/Users/emhun/Desktop/Tweets_GWR")

tracts <- readOGR("Data/Spatial",layer="TwtCnt_PntMW")
counties <- readOGR("Data/Spatial",layer="countiesTwt_sel")

nonContig <- c("03","07","14","64","15","60","02","81","64","84","86","67","89","68","71","76","69","70","95","43","72","74","52","78","79")

for (i in nonContig) {
  counties <- counties[substr(counties@data$GEOID10,1,2) != i,]
}

counties_cent <- gCentroid(counties, byid=TRUE, id=NULL)

counties_cent <- SpatialPointsDataFrame(counties_cent,counties@data)

colours_map <- c("dark blue", "blue", "red", "dark red")

bw <- ggwr.sel(tweets ~ pop, data=counties_cent, adapt=T, gweight=gwr.Gauss, family=poisson())

# for midwest Census Tract points...
# bw <- 0.015172167326049

gwr.model <- ggwr(tweets ~ pop, data=counties_cent, adapt=bw, family=poisson())

# t <- gwr.model$SDF$Poplog / gwr.model$SDF$Poplog_se
# sig.map <- SpatialPointsDataFrame(tracts,data.frame(t))

# colours_sig <- c("green","red","green")
# breaks <- c(-13,-1.645,1.645,max(t))
# spplot(sig.map, cuts = breaks, col.regions=colours_sig, cex = 0.3)

gwr.model
spplot(gwr.model$SDF, "pop", cuts=quantile(gwr.model$SDF$pop),col.regions=colours_map, cex=0.5)

writeOGR(gwr.model$SDF, "C:/Users/emhun/Desktop/Tweets_GWR/Data/Spatial", "countiesGWR", driver="ESRI Shapefile", overwrite_layer=TRUE)