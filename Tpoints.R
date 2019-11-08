#accepts a polygon area of interests. Selects
#by a query to provide catagories, creates randome points for training. creates a training point crv.

#load packages
require(bcdata)
require(tidyverse)
require(sf)
require(mapview)
require(raster)

# set test variables
layer <-  "e5bf92e9-3323-4eb6-b051-7fe89b5174a9"
aoifile <- "inputs/AOI/DeceptionProjectBoundary.shp"
fields <-  c("BCLCS_LEVEL_1","BCLCS_LEVEL_2")
npoints <- 10000

rstack <-

#read in area of interest polygon
aoi <- read_sf(aoifile)

# query and download data from bcdata
tpoly <- bcdc_query_geodata(layer) %>%
  filter(INTERSECTS(aoi)) %>%
  bcdata::select(query_fields) %>%
  collect()

#create random points in the aoi
points <- spsample(aoi,n = npoints,"random")
Tpoints <- raster:extract ()
