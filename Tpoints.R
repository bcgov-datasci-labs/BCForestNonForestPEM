#accepts a polygon area of interests. Selects
#by a query to provide catagories, creates randome points for training. creates a training point crv.

#load packages
require(c("bcdata", "dtidyverse", "sf", "mapView", "raster"))

# set test variables
layer = "e5bf92e9-3323-4eb6-b051-7fe89b5174a9"
aoifile <- "inputs/AOI/DeceptionProjectBoundary.shp"
fields = c("BCLCS_LEVEL_1","BCLCS_LEVEL_2")

aoi <- read_sf(aoifile)

# query the data
tpoly <- bcdc_query_geodata(layer) %>%
  filter(INTERSECTS(aoi)) %>%
  select(query_fields) %>%
  collect()
