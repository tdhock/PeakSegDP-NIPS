works_with_R("3.1.1", ggplot2="1.0")

load("dp.peaks.intervals.RData")
load("dp.peaks.sets.RData")
load("dp.peaks.optimal.RData")
load("dp.peaks.matrices.RData")

source("interval-regression.R")

g <- as.matrix(expand.grid(log.max.coverage=seq(2, 8, l=100),
                           log.total.weight=seq(6, 15, l=100)))
dp.peaks.grid.list <- list()
dp.peaks.polygon.list <- list()
dp.peaks.segment.list <- list()
dp.peaks.regression <- NULL
dp.peaks.prediction.list <- list()
getPolygons <- function(df){
  indices <- with(df, chull(log.max.coverage, log.total.weight))
  df[indices, ]
}
for(set.name in names(dp.peaks.intervals)){
  chunk.list <- dp.peaks.intervals[[set.name]]
  train.sets <- dp.peaks.sets[[set.name]]
  for(set.i in seq_along(train.sets)){
    testSet <- paste(set.name, "split", set.i)
    train.chunks <- train.sets[[set.i]]
    train.features <- NULL
    train.intervals <- NULL
    for(chunk.name in train.chunks){
      data.list <- chunk.list[[chunk.name]]
      train.features <- rbind(train.features, data.list$features)
      train.intervals <- rbind(train.intervals, data.list$intervals)
    }
    ##train.features <- train.features[, "log.max.coverage", drop=FALSE]
    fit <- regression.funs$square(train.features, train.intervals)
    dp.peaks.grid.list[[testSet]] <-
      data.frame(set.name, set.i,
                 testSet,
                 g, log.lambda=fit$predict(g))
    dp.peaks.prediction.list[[paste(testSet, "train")]] <-
      data.frame(set.name, set.i,
                 test.chunk=NA,
                 sample.id=NA,
                 testSet, set="train",
                 train.features,
                 log.lambda=fit$train.predict,
                 peaks=NA,
                 test.errors=0)
    ## Now use the model on the test chunks.
    test.chunks <- names(chunk.list)[!names(chunk.list) %in% train.chunks]
    for(test.chunk in test.chunks){
      error.list <- dp.peaks.matrices[[set.name]][[test.chunk]]
      data.list <- chunk.list[[test.chunk]]
      log.lambda.hat <- fit$predict(data.list$features)
      optimal.list <- dp.peaks.optimal[[set.name]][[test.chunk]]
      this.test <- data.frame(set.name, set.i,
                              test.chunk,
                              sample.id=names(optimal.list),
                              testSet, set="test",
                              data.list$features,
                              log.lambda=log.lambda.hat,
                              peaks=NA,
                              test.errors=NA,
                              row.names=NULL)
      for(sample.i in seq_along(optimal.list)){
        optimal.df <- optimal.list[[sample.i]]
        sample.id <- names(optimal.list)[[sample.i]]
        l <- log.lambda.hat[sample.i, ]
        pred.row <-
          subset(optimal.df, min.log.lambda < l & l < max.log.lambda)
        stopifnot(nrow(pred.row)==1)
        peaks <- this.test$peaks[[sample.i]] <-
          as.character(pred.row$model.complexity)
        errors <- this.test$test.errors[[sample.i]] <-
          error.list$PeakSeg[sample.i, peaks]
        regions <- error.list$regions[sample.i]
        dp.peaks.regression <- rbind(dp.peaks.regression, {
          data.frame(set.name, set.i, test.chunk,
                     sample.id,
                     peaks, errors, regions)
        })
      }
      if(nrow(this.test) == 2){
        one.seg <- this.test[1,]
        one.seg$log.max.coverage.end <- this.test[2, "log.max.coverage"]
        one.seg$log.total.weight.end <- this.test[2, "log.total.weight"]
        dp.peaks.segment.list[[paste(testSet, test.chunk)]] <-
          one.seg
      }else if(nrow(this.test) > 2){
        dp.peaks.polygon.list[[paste(testSet, test.chunk)]] <-
          getPolygons(this.test)
      }else{
        stop(nrow(this.test), "rows")
      }
      dp.peaks.prediction.list[[paste(testSet, test.chunk)]] <-
        this.test
    }
  }
}

dp.peaks.prediction <- do.call(rbind, dp.peaks.prediction.list)
dp.peaks.grid <- do.call(rbind, dp.peaks.grid.list)
dp.peaks.polygon <- do.call(rbind, dp.peaks.polygon.list)
dp.peaks.segment <- do.call(rbind, dp.peaks.segment.list)

save(dp.peaks.regression,
     dp.peaks.prediction,
     dp.peaks.grid,
     dp.peaks.polygon,
     dp.peaks.segment,
     file="dp.peaks.regression.RData")
