library(sf)
library(dplyr)
library(readr)
library(raster)

TmpDir <- 'tmp'
OutDir <- 'outputs'
DataDir <- 'inputs'
dataOutDir <- file.path(OutDir,'inputs')
tileOutDir <- file.path(dataOutDir,'tile')

dir.create(TmpDir, showWarnings = FALSE)
dir.create(OutDir, showWarnings = FALSE)
dir.create(DataDir, showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(tileOutDir), showWarnings = FALSE)

