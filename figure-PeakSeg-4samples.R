works_with_R("3.1.1", ggplot2="1.0",
             dplyr="0.2", PeakSeg="1.0")

load("PeakSeg4samples.RData")

ann.colors <-
  c(noPeaks="#f6f4bf",
    peakStart="#ffafaf",
    peakEnd="#ff4c4c",
    peaks="#a445ee")

error.list <- PeakSeg4samples$regions
errors <- NULL
for(peaks in 0:4){
  rname <- paste0("PeakSeg", peaks)
  e <- error.list[[rname]] %.%
    group_by(sample.id) %.%
    summarise(errors=sum(fp+fn))
  errors <- rbind(errors, data.frame(peaks, e))
}
errplot <- 
ggplot(errors, aes(peaks, errors))+
  geom_line()+
  geom_point()+
  theme_bw()+
  facet_grid(sample.id ~ .)+
  scale_y_continuous("incorrect annotated regions", minor_breaks=NULL)+
  scale_x_continuous("model complexity (peaks)", minor_breaks=NULL)+
  theme(panel.margin=grid::unit(0, "cm"))+
  coord_cartesian(ylim=c(-0.5, 3.5))
pdf("figure-PeakSeg-4samples-errors.pdf", h=5, w=7)
print(errplot)
dev.off()

zero.errors <- subset(errors, errors==0)
errtext <- errplot+
  geom_text(aes(2, 2, label=label), color="green",
            data=data.frame(sample.id=sprintf("McGill%04d", c(2, 4, 91, 322)),
              label=paste("best =", c("{2}", "{2}", "{1, 2, 3, 4}", "{1, 2}"))))+
  geom_point(color="green", data=zero.errors)
pdf("figure-PeakSeg-4samples-errors-text.pdf", h=5, w=7)
print(errtext)
dev.off()

for(model.name in names(error.list)){
  model.regions <- error.list[[model.name]]
  model.peaks <- PeakSeg4samples$peaks[[model.name]] %.%
    filter(sample.id %in% model.regions$sample.id)

  tit <- 
    c(PeakSeg="PeakSeg, max.peaks=2",
      PeakSeg2="PeakSeg, max.peaks=2",
      PeakSeg0="PeakSeg, max.peaks=0",
      PeakSeg1="PeakSeg, max.peaks=1",
      PeakSeg3="PeakSeg, max.peaks=3",
      PeakSeg4="PeakSeg, max.peaks=4",
      macs="macs, log(qvalue)=2.1",
      "macs-default"="macs, log(qvalue)=1.30103")[[model.name]]

  fakeX <- 118079
  no.peaks <- 
ggplot()+
  geom_tallrect(aes(xmin=fakeX, xmax=fakeX,
                    linetype=status, fill=annotation),
                data=model.regions,
                fill=NA, color="black", size=1)+
  coord_cartesian(xlim=c(118080, 118130))+
  theme_bw()+
  theme(panel.margin=grid::unit(0, "cm"))+
  facet_grid(sample.id ~ ., scales="free")+
  scale_y_continuous("aligned read coverage",
                     labels=function(x){
                       sprintf("%.1f", x)
                     },
                     breaks=function(limits){
                       limits[2]
                     })+
  xlab("position on chr11 (kilo base pairs)")+
  guides(linetype=guide_legend(order=2,
           override.aes=list(fill="white")))+
  geom_line(aes(first.base/1e3, count),
            data=PeakSeg4samples$signal, color="grey50")+
  ggtitle(tit)

  if(model.name=="macs-default"){
    png(sprintf("figure-%s-4samples-nopeaks.png", model.name),
        units="in", res=200, width=7, height=5)
    print(no.peaks)
    dev.off()

    no.regions <- no.peaks+
  geom_point(aes(chromStart/1e3, 0),
             data=model.peaks,
             pch=1, size=2, color="deepskyblue")+
  geom_segment(aes(chromStart/1e3, 0,
                   xend=chromEnd/1e3, yend=0),
               data=model.peaks, size=2, color="deepskyblue")

    png(sprintf("figure-%s-4samples-noregions.png", model.name),
        units="in", res=200, width=7, height=5)
    print(no.regions)
    dev.off()
  }
  
  just.regions <- 
ggplot()+
  ggtitle(tit)+
  scale_y_continuous("aligned read coverage",
                     labels=function(x){
                       sprintf("%.1f", x)
                     },
                     breaks=function(limits){
                       limits[2]
                     })+
  xlab("position on chr11 (kilo base pairs)")+
  theme_bw()+
  theme(panel.margin=grid::unit(0, "cm"))+
  facet_grid(sample.id ~ ., scales="free")+
  scale_fill_manual("annotation", values=ann.colors,
                    breaks=names(ann.colors))+
  coord_cartesian(xlim=c(118080, 118130))+
  geom_tallrect(aes(xmin=118000, xmax=118000, linetype=status),
                data.frame(status=c("false negative", "false positive")))+
  geom_tallrect(aes(xmin=chromStart/1e3, xmax=chromEnd/1e3,
                    fill=annotation),
                data=model.regions, alpha=1/2)+
  scale_linetype_manual("error type",
                        values=c(correct=0,
                          "false negative"=3,
                          "false positive"=1))+
  guides(linetype=guide_legend(order=2,
           override.aes=list(fill="white")))+
  geom_line(aes(first.base/1e3, count),
            data=PeakSeg4samples$signal, color="grey50")
  
  png(sprintf("figure-%s-4samples-just-regions.png", model.name),
      units="in", res=200, width=7, height=5)
  print(just.regions)
  dev.off()
  
  if(nrow(model.peaks)){
    with.peaks <-
      just.regions+
  geom_point(aes(chromStart/1e3, 0),
             data=model.peaks,
             pch=1, size=2, color="deepskyblue")+
  geom_segment(aes(chromStart/1e3, 0,
                   xend=chromEnd/1e3, yend=0),
               data=model.peaks, size=2, color="deepskyblue")
  }

  png(sprintf("figure-%s-4samples-with-peaks.png", model.name),
      units="in", res=200, width=7, height=5)
  print(with.peaks)
  dev.off()
    
  with.peaks.errors <- with.peaks+
  geom_tallrect(aes(xmin=chromStart/1e3, xmax=chromEnd/1e3,
                    linetype=status),
                data=model.regions,
                fill=NA, color="black", size=1)

  png(sprintf("figure-%s-4samples.png", model.name),
      units="in", res=200, width=7, height=5)
  print(with.peaks.errors)
  dev.off()
}

just.regions <- 
  ggplot()+
  scale_y_continuous("aligned read coverage",
                     labels=function(x){
                       sprintf("%.1f", x)
                     },
                     breaks=function(limits){
                       limits[2]
                     })+
  xlab("position on chr11 (kilo base pairs)")+
  theme_bw()+
  theme(panel.margin=grid::unit(0, "cm"))+
  facet_grid(sample.id ~ ., scales="free")+
  scale_fill_manual("annotation", values=ann.colors,
                    breaks=names(ann.colors))+
  coord_cartesian(xlim=c(118080, 118130))+
  geom_tallrect(aes(xmin=chromStart/1e3, xmax=chromEnd/1e3,
                    fill=annotation),
                data=model.regions, alpha=1/2)+
  guides(linetype=guide_legend(order=2,
           override.aes=list(fill="white")))+
  geom_line(aes(first.base/1e3, count),
            data=PeakSeg4samples$signal, color="grey50")

png(sprintf("figure-4samples-just-regions.png", model.name),
    units="in", res=200, width=7, height=5)
print(just.regions)
dev.off()

