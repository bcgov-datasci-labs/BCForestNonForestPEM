rm(list = ls(all.names = TRUE))

list.of.packages <- c("mlr", "caret", "rgdal")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, dependencies = TRUE)

library(mlr)


#SuperLearner approach to ensemble machine learning that penalizes poor performing models

att.T <- read.csv()



