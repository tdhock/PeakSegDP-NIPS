works_with_R("3.1.1", 
             "tdhock/PeakError@d9196abd9ba51ad1b8f165d49870039593b94732")

load("dp.peaks.RData")

prefix <- "http://cbio.ensmp.fr/~thocking/chip-seq-chunk-db"

dp.peaks.error <- list()
for(region.i in seq_along(dp.peaks)){
  region.str <- names(dp.peaks)[[region.i]]
  cat(sprintf("%4d / %4d %s\n", region.i, length(dp.peaks), region.str))
  u <- url(sprintf("%s/%s/regions.RData", prefix, region.str))
  load(u)
  close(u)
  type.list <- split(regions, regions$cell.type, drop=TRUE)
  peak.samples <- dp.peaks[[region.str]]
  chunk.list <- list()
  for(cell.type in names(type.list)){
    one.type <- type.list[[cell.type]]
    region.samples <- split(one.type, one.type$sample.id, drop=TRUE)
    type.df <- NULL
    some.samples <- intersect(names(peak.samples), names(region.samples))
    for(sample.id in some.samples){
      regions <- region.samples[[sample.id]]
      peak.list <- peak.samples[[sample.id]]
      for(peaks.str in names(peak.list)){
        peak.df <- peak.list[[peaks.str]]
        err.df <- PeakErrorChrom(peak.df, regions)
        type.df <- rbind(type.df, {
          data.frame(sample.id, param.name=as.character(peaks.str), err.df)
        })
      }
    }
    chunk.list[[cell.type]] <- type.df
  }
  dp.peaks.error[[region.str]] <- chunk.list
}

save(dp.peaks.error, file="dp.peaks.error.RData")
