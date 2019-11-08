#accepts a polygon area of interests. Selects 
#by a query to provide catagories, creates randome points for training. creates a training point crv.

<<<<<<< HEAD
library(bcdata)
library(tidyverse)
library(mapview)
library(sf) # this is for reading in the aoi .shp for initial testing

# Here we are grabbing a bunch of data from bcdata to make a map of bc looking at fire and transmission lines

aoifile <- "inputs/AOI/DeceptionProjectBoundary.shp"

aoi <- read_sf(aoifile)

tpoly <- bcdc_query_geodata('vri-forest-vegetation-composite-polygons-and-rank-1-layer') %>% #query_geodata will just query whats available, not acquire it
  filter(INTERSECTS(aoi)) %>%
  select(BCLCS_LEVEL_1) %>% # this will filter data from geodata BEFORE it sends it over, so we're only grabbing the 2017 data from the web
collect() # collect() will collect the data that you've queried
=======
# set test variables
layer = "e5bf92e9-3323-4eb6-b051-7fe89b5174a9"
query = 
input

#load pacakges
require(c("bcdata", "dtidyverse", "sf", "mapView" ))



#load BCDATA
>>>>>>> 2fc775f4668b3cfd0ea5bedcfcceec6a83ea531e
