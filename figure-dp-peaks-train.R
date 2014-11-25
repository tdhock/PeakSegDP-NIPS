works_with_R("3.1.1",
             "tdhock/ggplot2@aac38b6c48c016c88123208d497d896864e74bd7",
             reshape2="1.2.2",
             xtable="1.7.3",
             dplyr="0.3.0.2")

load("dp.peaks.train.RData")
load("dp.peaks.error.RData")
load("dp.peaks.RData")

groups <- dp.peaks.train %>%
  mutate(group=paste(chunk.name, cell.type))
good.group.df <- groups %>%
  group_by(group) %>%
  summarise(region.values=length(unique(regions))) %>%
  filter(region.values == 1)
good.groups <- good.group.df$group
min.error <- groups %>%
  filter(group %in% good.groups) %>%
  group_by(chunk.name, cell.type, algorithm, regions) %>%
  summarise(min=min(errors)) %>%
  mutate(set.name=sub("/.*", "", chunk.name),
         experiment=sub("_.*", "", set.name))
wide <-
  dcast(min.error,
        chunk.name + cell.type + experiment ~ algorithm,
        value.var="min") %>%
  mutate(baseline=ifelse(experiment=="H3K36me3",
           hmcan.broad.trained, macs.trained),
         advantage=baseline-PeakSegDP) %>%
  arrange(advantage)
zero.error <- data.table(wide) %>%
  filter(PeakSegDP==0)
biggest <- zero.error %>%
  group_by(experiment) %>%
  mutate(rank=rank(-advantage)) %>%
  filter(rank==1)
data.frame(biggest)

## We will make a plot for the window for which we have the biggest
## advantage, for each mark type.
prefix <- "http://cbio.ensmp.fr/~thocking/chip-seq-chunk-db"

for(experiment.i in 1:nrow(biggest)){
  chunk.info <- biggest[experiment.i, ]
  experiment <- as.character(chunk.info$experiment)
  chunk.name <- as.character(chunk.info$chunk.name)
  cell.type <- as.character(chunk.info$cell.type)
  other.algo <-
    ifelse(experiment=="H3K4me3", "macs.trained", "hmcan.broad.trained")
  algorithms <- c("PeakSegDP", other.algo)
  param.err <- dp.peaks.train %>%
    inner_join(chunk.info) %>%
    mutate(param.name=as.character(param.num))
  min.params <- param.err %>%
    filter(algorithm %in% algorithms) %>%
    group_by(algorithm) %>%
    filter(seq_along(errors) == which.min(errors))
  default.param.val <-
    ifelse(other.algo=="macs.trained", "1.30103", "2.30258509299405")
  default.param <- param.err %>%
    filter(algorithm==other.algo,
           param.name==default.param.val) %>%
    mutate(algorithm=sub("trained", "default", algorithm))
  show.params <- rbind(default.param, min.params)
  ## TODO: download peaks and error regions for baseline, plot them
  ## alongside PeakSeg model.
  dp.error <- dp.peaks.error[[chunk.name]][[cell.type]]
  sample.ids <- as.character(unique(dp.error$sample.id))
  dp.peaks.samples <- dp.peaks[[chunk.name]]
}
