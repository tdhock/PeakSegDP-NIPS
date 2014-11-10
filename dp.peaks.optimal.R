works_with_R("3.1.1", PeakSeg="2014.10.6")

load("dp.peaks.matrices.RData")

dp.peaks.optimal <- list()
for(set.name in names(dp.peaks.matrices)){
  chunk.list <- dp.peaks.matrices[[set.name]]
  for(chunk.name in names(chunk.list)){
    err.mat <- chunk.list[[chunk.name]]$PeakSeg
    for(sample.id in rownames(err.mat)){
      cat(sprintf("%s %s\n", sample.id, chunk.name))
      model.file <-
        sprintf("benchmark/%s/%s/dp.model.RData", sample.id, chunk.name)
      load(model.file)
      model.list <- split(dp.model, dp.model$peaks)
      coverage.file <-
        sprintf("benchmark/%s/%s/coverage.RData", sample.id, chunk.name)
      load(coverage.file)
      loss.df <- NULL
      for(peaks in names(model.list)){
        model.df <- model.list[[peaks]]
        model.losses <- list()
        model.weights <- 0
        for(segment.i in 1:nrow(model.df)){
          first.i <- which(coverage$chromStart==model.df$chromStart[segment.i])
          last.i <- which(coverage$chromEnd==model.df$chromEnd[segment.i])
          seg.data <- coverage[first.i:last.i, ]
          bases <- with(seg.data, chromEnd-chromStart)
          seg.mean <- sum(seg.data$coverage*bases)/sum(bases)
          stopifnot(seg.mean == model.df$mean[segment.i])
          model.losses[[segment.i]] <- if(seg.mean==0){
            0
          }else{
            sum(bases * (seg.mean - seg.data$coverage*log(seg.mean)))
          }
          model.weights <- model.weights + sum(bases)
        }
        model.loss <- sum(unlist(model.losses))
        loss.df <- rbind(loss.df, {
          data.frame(peaks=as.integer(peaks), loss=model.loss,
                     weights=model.weights)
        })
      }
      ## Why does the cost increase with model complexity?
      while(length(next.bigger <- which(diff(loss.df$loss) > 0))){
        loss.df <- loss.df[-(next.bigger[1]+1), ]
      }
      dp.peaks.optimal[[set.name]][[chunk.name]][[sample.id]] <-
        with(loss.df, exactModelSelection(loss, peaks))
    }
  }
}

save(dp.peaks.optimal, file="dp.peaks.optimal.RData")
