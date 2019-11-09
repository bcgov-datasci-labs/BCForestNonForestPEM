#accepts a polygon area of interests. Selects
#by a query to provide catagories, creates randome points for training. creates a training point crv.

#load packages
library(bcdata)
library(tidyverse)
library(sf)
library(mapview)
library(raster)
library(ggplot2)
library(sp)


# set test variables
layer <-  "vri-forest-vegetation-composite-polygons-and-rank-1-layer" #shoud use permalink but it was not working
aoifile <- "inputs/AOI/DeceptionProjectBoundary.shp"
npoints <- 10000
rstack <-
#rstack <-
field <- "BCLCS_LEVEL_1"

makeTpoints <- function(aoifile, layer, field, npoints) {
  #read in area of interest polygon
  aoi <- read_sf(aoifile)

  # download data from bcdata.
  tpoly <- bcdc_query_geodata(layer) %>%
    bcdata::filter(INTERSECTS(aoi)) %>%
    bcdata::select(!!field) %>% #!! will let you get into the variable field. Otherwise it will try to find a field called field.
    collect()

  #create random points in the aoi
  points <- st_sample (aoi, size = npoints, type = "random")
  st_crs(points) <- 3005
  Tpoints <- st_intersection (points, tpoly) #THIS IS NOT WORKING YET!

  return(points)#NEED TO CHANGE THIS TO Tpoints once line 35 is working.
}


points <- makeTpoints(aoifile, layer, field, npoints)
ggplot2::ggplot()+
  geom_sf(data = tpoly, aes(fill = !!field))+
  geom_sf(data = points, size = 0.5, color = "yellow")
