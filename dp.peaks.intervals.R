works_with_R("3.1.1", PeakSeg="1.0")

load("dp.peaks.optimal.RData")
load("dp.peaks.matrices.RData")

dp.peaks.intervals <- list()
for(set.name in names(dp.peaks.matrices)){
  matrices <- dp.peaks.matrices[[set.name]]
  optimal <- dp.peaks.optimal[[set.name]]
  for(chunk.name in names(optimal)){
    optimal.list <- optimal[[chunk.name]]
    error.mat <- matrices[[chunk.name]]$PeakSeg
    chunk.intervals <- NULL
    chunk.features <- NULL
    for(sample.id in names(optimal.list)){
      coverage.file <-
        sprintf("benchmark/%s/%s/coverage.RData", sample.id, chunk.name)
      load(coverage.file)
      one.feature <- with(coverage, {
        cbind(log.max.coverage=log(max(coverage)),
              log.total.weight=log(sum(chromEnd-chromStart)))
      })
      optimal.df <- optimal.list[[sample.id]]
      param.name <- as.character(optimal.df$model.complexity)
      optimal.df$error <- error.mat[sample.id, param.name]
      indices <- with(optimal.df, {
        largestContinuousMinimum(error, max.log.lambda-min.log.lambda)
      })
      one.interval <- 
        cbind(min.log.lambda=optimal.df$min.log.lambda[indices$start],
              max.log.lambda=optimal.df$max.log.lambda[indices$end])
      rownames(one.interval) <- rownames(one.feature) <-
        paste(chunk.name, sample.id)
      chunk.intervals <- rbind(chunk.intervals, one.interval)
      chunk.features <- rbind(chunk.features, one.feature)
    }
    dp.peaks.intervals[[set.name]][[chunk.name]] <-
      list(features=chunk.features, intervals=chunk.intervals)
  }
}

save(dp.peaks.intervals, file="dp.peaks.intervals.RData")
