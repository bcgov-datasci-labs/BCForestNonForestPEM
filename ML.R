rm(list = ls(all.names = TRUE))

#install and load packages
list.of.packages <- c("mlr", "caret", "rgdal", "sf", "mapview","dplyr", "deepnet","glmnet")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, dependencies = TRUE)

library(mlr)
library(caret)
library(rgdal)
library(sf)
library(mapview)
library(dplyr)
library(readr)
library(deepnet)
library(glmnet)


#Set inputs
dirpath <- "ML_WL_test_data/"
filename<- "WL_training_points_attd.csv"
filecov<-"rastLUT.csv"
ycol <-"coords.x1"
xcol<-"coords.x2"
epsg <- 3005
respV <- "T_W_WL"

#SuperLearner approach to ensemble machine learning that penalizes poor performing models

att.T <- read_csv(paste(dirpath, filename, sep=""))
cov <- read_csv(paste(dirpath, filecov, sep=""), col_names = FALSE)
covList <- cov[,2, drop = TRUE]
att.Tsp <- st_as_sf(att.T,
                        coords =c(ycol, xcol),
                        crs = epsg)

#mapview is very slow but can be used to verify data
#mapview(att.Tsp)

df = att.T %>%
  dplyr::select(covList, respV)

dfcomp<-df[complete.cases(df),]

fitControl <- trainControl(method="repeatedcv", number=3, repeats=2)

#RandomForest
mFit3 <- caret::train(T_W_WL~ahm_clip+ahm_clip+aspect1+B1_LANDSAT+B1_SENT2+B10_SENT2+B11_SENT2+B12_SENT2+B13_SENT2+B2_LANDSAT+B2_SENT2+B3_LANDSAT+B3_SENT2+B4_SENT2+B5_SENT2+B6_SENT2+B7_SENT2+B8_SENT2+B9_SENT2+bffp_clip+carea+cmd_clip+cplan+cprof+DAH+dd0_clip+dd18_clip+dd5_clip+effp_clip+elev+emt_clip+eref_clip+ext_clip+ffp_clip+map_clip+mar_clip+mat_clip+mcmt_clip+mrvbf+msp_clip+mwmt_clip+nffd_clip+pas_clip+rh_clip+shm_clip3+slope+TOPOwet+TPI,
                    data=dfcomp, method="ranger",
                    trControl=fitControl, na.action=na.omit)



############################################################################################
#Ensemble modeling methods below are currently in development
#Additional testing required
############################################################################################



########parameter tuning requires some additional testing########
#https://github.com/Envirometrix/PNVmaps/blob/master/R_code/PNV250m_prediction.R#L220
tsk = makeClassifTask(data = dfcomp, target = respV)
ps = makeParamSet(makeDiscreteParam("mtry", values = seq(1, 47, by=5)))
ctrl = makeTuneControlGrid()
rdesc = makeResampleDesc("CV", iters = 3L)
res = tuneParams("classif.ranger", task = tsk, resampling = rdesc, par.set = ps, control = ctrl)
res

#####Feature selection classif.ranger requires additional testing#####
outer = makeResampleDesc("CV", iters = 3L)
inner = makeResampleDesc("Holdout")
ctrl = makeFeatSelControlRandom(maxit = 20)
lrn.rf = mlr::makeLearner("classif.ranger", num.threads = parallel::detectCores(), mtry=res$x$mtry, num.trees=40)
lrn1 = makeFeatSelWrapper(lrn.rf, resampling = inner, control = ctrl, show.info=TRUE)
parallelMap::parallelStartSocket(parallel::detectCores())
mod1 = mlr::train(lrn1, task = tsk)
parallelMap::parallelStop()
sfeats1 = getFeatSelResult(mod1)
str(sfeats1$x)
sfeats1

#####Ensemble model###################
tsk = makeClassifTask(data = dfcomp, target = respV)
base = c("classif.ranger", "classif.nnTrain", "classif.xgboost")
lrns = lapply(base, makeLearner)
m = makeStackedLearner(base.learners = lrns,
                       predict.type = "prob", method = "stack.cv", super.learner="classif.glmnet")
tmp = mlr::train(m, tsk)
#tmp$learner.model$super.model$learner.model
res = predict(tmp, newdata=meuse.grid@data)
meuse.grid$mlr.om = res$data$response
spplot(meuse.grid["mlr.om"])


