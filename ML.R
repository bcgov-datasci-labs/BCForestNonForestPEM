rm(list = ls(all.names = TRUE))

list.of.packages <- c("mlr", "caret", "rgdal")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, dependencies = TRUE)

library(mlr)
library(caret)
library(rgdal)

getwd()

dirpath <- "ML_WL_test_data/"
filename<- "WL_training_points_attd.csv"
latcol <-"coords.x1"
longcol<-"coords.x2"

#SuperLearner approach to ensemble machine learning that penalizes poor performing models

att.T <- read.csv(paste(dirpath, filename, sep=""),header=TRUE, sep=",")
att.Tsp <- st_as_sf(att.T,
                        coords =c(longcol, latcol),
                        crs = 4326)


t.pnts<- att.T$T_W_WL


