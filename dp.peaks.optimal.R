works_with_R("3.1.1",
             "tdhock/PeakSegDP@5bcee97f494dcbc01a69e0fe178863564e9985bc")

load("dp.peaks.matrices.RData")

dp.peaks.optimal <- list()
for(set.name in names(dp.peaks.matrices)){
  chunk.list <- dp.peaks.matrices[[set.name]]
  for(chunk.name in names(chunk.list)){
    err.mat <- chunk.list[[chunk.name]]$PeakSeg
    model.file <- sprintf("data/%s/dp.model.RData", chunk.name)
    load(model.file)
    for(sample.id in rownames(err.mat)){
      cat(sprintf("%s %s\n", sample.id, chunk.name))
      sample.model <- dp.model[[sample.id]]
      dp.peaks.optimal[[set.name]][[chunk.name]][[sample.id]] <-
        with(sample.model$error, exactModelSelection(error, peaks))
    }
  }
}

save(dp.peaks.optimal, file="dp.peaks.optimal.RData")
