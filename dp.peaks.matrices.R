works_with_R("3.1.1", dplyr="0.2")

load("dp.peaks.error.RData")

prefix <- "http://cbio.ensmp.fr/~thocking/chip-seq-chunk-db"

set.names <- unique(sub("/.*", "", names(dp.peaks.error)))

dp.peaks.matrices <- list()
for(set.name in set.names){
  chunk.names <- grep(set.name, names(dp.peaks.error), value=TRUE)
  for(chunk.name in chunk.names){
    print(chunk.name)
    chunk.list <- dp.peaks.error[[chunk.name]]
    chunk.df <- do.call(rbind, chunk.list)
    long <- chunk.df %.%
      mutate(param.num=as.numeric(as.character(param.name))) %.%
      group_by(sample.id, param.num) %.%
      summarise(errors=sum(fp+fn),
                regions=n())
    long.list <- split(long, long$sample.id, drop=TRUE)
    err.mat <- matrix(NA, length(long.list), 10,
                      dimnames=list(sample.id=names(long.list),
                        param.name=0:9))
    for(row.i in seq_along(long.list)){
      sample.df <- long.list[[row.i]]
      param.name <- as.character(sample.df$param.num)
      err.mat[row.i, param.name] <- sample.df$errors
    }
    err.list <-
      list(PeakSeg=err.mat,
           regions=sapply(long.list, function(x)x$regions[[1]]))

    for(algorithm in c("macs.trained", "hmcan.broad.trained")){
      u <- url(sprintf("%s/%s/error/%s.RData", prefix, chunk.name, algorithm))
      load(u)
      close(u)
      a.df <- error %.%
        filter(sample.id %in% rownames(err.mat)) %.%
        mutate(param.num=as.numeric(as.character(param.name))) %.%
        group_by(sample.id, param.num) %.%
        summarise(errors=sum(fp+fn),
                  regions=sum(fp+fn))
      alist <- split(a.df, a.df$sample.id, drop=TRUE)
      alg.mat <- t(sapply(alist, "[[", "errors"))
      colnames(alg.mat) <- alist[[1]]$param.num
      err.list[[algorithm]] <- alg.mat
    }

    dp.peaks.matrices[[set.name]][[chunk.name]] <- err.list
  }
}

save(dp.peaks.matrices, file="dp.peaks.matrices.RData")
