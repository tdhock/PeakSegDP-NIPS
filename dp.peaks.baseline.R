load("dp.peaks.sets.RData")
load("dp.peaks.matrices.RData")

pick.best.index <- structure(function
### Minimizer for local models, described in article section 2.3
### "Picking the optimal model"
(err
### Vector of errors to minimize.
 ){
  nparam <- length(err)
  candidates <- which(err==min(err))
  if(length(err)==1)return(candidates)
  st <- abs(median(candidates)-candidates)
  middle <- candidates[which.min(st)]
  if(all(diff(err)==0))return(middle)
  if(nparam %in% candidates && 1 %in% candidates){
    cat("Warning: strange error profile, picking something near the center\n")
    print(as.numeric(err))
    d <- diff(candidates)>1
    if(any(d)){
      which(d)[1]
    }else{
      middle
    }
  }else if(1 %in% candidates){
    max(candidates)
  }else if(nparam %in% candidates){
    min(candidates)
  }else {
    middle
  }
### Integer index of the minimal error.
},ex=function(){
  stopifnot(pick.best.index(rep(0,100))==50)

  err <- rep(1,100)
  err[5] <- 0
  stopifnot(pick.best.index(err)==5)

  ## should pick the middle
  err <- rep(1,100)
  err[40:60] <- 0
  stopifnot(pick.best.index(err)==50)

  ## should pick the biggest
  err <- rep(1,100)
  err[1:60] <- 0
  stopifnot(pick.best.index(err)==60)

  ## should pick the smallest
  err <- rep(1,100)
  err[50:100] <- 0
  stopifnot(pick.best.index(err)==50)
})

dp.peaks.baseline <- NULL
for(set.name in names(dp.peaks.sets)){
  train.sets <- dp.peaks.sets[[set.name]]
  error.list <- dp.peaks.matrices[[set.name]]
  for(set.i in seq_along(train.sets)){
    train.chunks <- train.sets[[set.i]]
    test.chunks <- names(error.list)[!names(error.list) %in% train.chunks]
    for(algorithm in c("hmcan.broad.trained", "macs.trained")){
      train.mat <- NULL
      for(train.chunk in train.chunks){
        train.mat <- rbind(train.mat, error.list[[train.chunk]][[algorithm]])
      }
      error.curve <- colSums(train.mat)
      picked <- pick.best.index(error.curve)
      test.mat <- NULL
      test.regions <- NULL
      for(test.chunk in test.chunks){
        test.mat <- rbind(test.mat, error.list[[test.chunk]][[algorithm]])
        test.regions <- c(test.regions, error.list[[test.chunk]]$regions)
      }
      errors <- sum(test.mat[,picked])
      regions <- sum(test.regions)
      dp.peaks.baseline <- rbind(dp.peaks.baseline, {
        data.frame(set.name, set.i, algorithm,
                   param.name=colnames(train.mat)[picked],
                   errors, regions)
      })
    }
  }
}

save(dp.peaks.baseline, file="dp.peaks.baseline.RData")
