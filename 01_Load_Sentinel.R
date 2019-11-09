#ImageLoad for BCForestNonForestPEM Hackathon 2019


#Load Packages
devtools::install_github("16EAGLE/getSpatialData")
library(getSpatialData)
library(raster)
library(sf)
library(sp)
library(mapview)


#Directory Variable names
AOI.dir <- 'inputs/AOI'
Sent.dir <- 'satellite/archive'

AOI<-st_read(file.path(AOI.dir,'DeceptionProjectBoundary.shp'))
AOI<-st_set_crs(AOI,'+init=epsg:3005')
#Set AOI, expects a "SpatialPolygonsDataFrame", check AOI class
#class(AOI_sp)
AOI_sp<-as(AOI,'Spatial')
#getSpatialData::services_avail()

# Manually Set an Area of Interest
set_aoi(AOI_sp)

# Login to Copernicus Data Hub (https://scihub.copernicus.eu/dhus/)
login_CopHub(username = "whmacken")
set_archive("satellite/archive")

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

#
# # Read as sf and calculate road lengths
# roads_sf <- read_sf(Rd_gdb, layer = "integrated_roads") %>%
#   mutate(rd_len = st_length(.))
#
# # Convert to TIFF
# datasets_prep <- unzip(datasets)


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

writeRaster(x = stack(jp2_10_crop_20, jp2_20_crop), "T10UEE_20190529T191911_20m.tif")
