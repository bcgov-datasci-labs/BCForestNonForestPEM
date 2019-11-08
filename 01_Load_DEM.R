# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

source('header.R')

#DEMLoad for BCForestNonForestPEM Hackathon 2019

#
DEM.dir<-'inputs/DEM_derived'
AOI.dir<-'inputs/AOI'
Image.dir<-'data/imagery'
DEM.out.dir<-'data'

DEM25<-raster(file.path(DEM.dir,'MRVBF25m.tif'))

AOI<-st_read(file.path(AOI.dir,'DeceptionProjectBoundary.shp'))
AOI<-st_set_crs(AOI,'+init=epsg:3005')

AOI.bbox<-st_bbox(AOI)

AOIRast<-raster(xmn=AOI.bbox[1], xmx=AOI.bbox[3],
                 ymn=AOI.bbox[2], ymx=AOI.bbox[4],
                 crs="+init=epsg:3005",
                 res = c(10,10), vals = 0)
#DEM10<-raster::disaggregate(DEM25, fact=2.5)
DEM10<-raster::resample(DEM25, AOIRast, method='ngb')
writeRaster(DEM10,filename=file.path('./data/DEM10.tif'), format="GTiff", overwrite=TRUE)




#code for reading from
railways <- bcdc_get_data("railway-track-line",
                          resource = "bf30d34e-1f6b-4034-a35c-1cf7c9707ae7")
# OR: railways <- bcdc_get_data("WHSE_BASEMAPPING.GBA_RAILWAY_TRACKS_SP")
railways


ggplot() +
  geom_sf(data = railways, aes(colour = USE_TYPE))


## ------------------------------------------------------------------------
railways <- select(railways, TRACK_NAME, TRACK_CLASSIFICATION,
                   USE_TYPE)
railways


## ------------------------------------------------------------------------
st_length(railways)


## ------------------------------------------------------------------------
railways <- mutate(railways, track_length = st_length(geometry))


## ------------------------------------------------------------------------
long_railways <- filter(railways, as.numeric(track_length) > 5000)


## ------------------------------------------------------------------------
library(units)
long_railways <- filter(railways, track_length > as_units(5000, "m"))









#Directory Variable names
AOI.dir <- 'inputs/AOI'
Sent.dir <- 'data/archive'

AOI<-st_read(file.path(AOI.dir,'DeceptionProjectBoundary.shp'))
AOI<-st_set_crs(AOI,'+init=epsg:3005')
#Set AOI, expects a "SpatialPolygonsDataFrame", check AOI class
#class(AOI_sp)
AOI_sp<-as(AOI,'Spatial')
#getSpatialData::services_avail()

# Manually Set an Area of Interest
set_aoi(AOI_sp)

# Login to Copernicus Data Hub (https://scihub.copernicus.eu/dhus/)
login_CopHub(username = "bevingtona")
set_archive("data/archive")

# Use getSentinel_query to search for data (using the session AOI)
records <- getSentinel_query(time_range = c("2018-07-01",
                                            "2018-08-30"),
                             platform = "Sentinel-2")


records <- records[which(records$cloudcoverpercentage < 10),] #filter by Level
records <- records[which(records$processinglevel == "Level-1C"),] #filter by Level

# Preview on Map

getSentinel_preview(records[7,])

# Download
datasets <- getSentinel_data(records = records[7, ])

sentFile <- list.files(file.path(Sent.dir), pattern = ".zip", full.names = TRUE)[1]
fc_list <- st_layers(sentFile)


# Read as sf and calculate road lengths
roads_sf <- read_sf(Rd_gdb, layer = "integrated_roads") %>%
  mutate(rd_len = st_length(.))

# Convert to TIFF
datasets_prep <- unzip(datasets)


jp2 <- list.files(path = "C:/Users/bevington/Dropbox/FLNRO_p1/!_Presentations/2019 11 05 R Geospatial/bcgov-r-geo-workshop/data/20191106_Day_2_PM_Raster/IMG_DATA", full.names = T)

jp2_10 <- stack(jp2[c(2,3,4,8)])
jp2_20 <- stack(jp2[c(5,6,7,11,12,13)])
jp2_60 <- stack(jp2[c(1,9,10)])

aoi <- mapview::viewRGB(x = jp2_10,
                        r = "T10UEE_20190529T191911_B04",
                        g = "T10UEE_20190529T191911_B03",
                        b = "T10UEE_20190529T191911_B02",
                        maxpixels = 1e+05) %>% mapedit::editMap()

mask <- aoi$finished %>% st_transform(crs(jp2_10))
jp2_10_crop <- crop(jp2_10, mask)
jp2_20_crop <- crop(jp2_20, mask)
jp2_60_crop <- crop(jp2_60, mask)

jp2_10_crop_20 <- resample(jp2_10_crop, jp2_20_crop)

writeRaster(x = stack(jp2_10_cr


                      op_20, jp2_20_crop), "T10UEE_20190529T191911_20m.tif")
