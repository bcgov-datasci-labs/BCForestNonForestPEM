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




#code for reading from bcgw
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

