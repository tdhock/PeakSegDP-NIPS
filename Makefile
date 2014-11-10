HOCKING-RIGAILL-chip-seq-NIPS.pdf: HOCKING-RIGAILL-chip-seq-NIPS.tex refs.bib figure-Segmentor-PeakSeg.png table-dp-peaks-regression.tex
	rm -f *.aux *.bbl
	pdflatex HOCKING-RIGAILL-chip-seq-NIPS
	bibtex HOCKING-RIGAILL-chip-seq-NIPS
	pdflatex HOCKING-RIGAILL-chip-seq-NIPS
	pdflatex HOCKING-RIGAILL-chip-seq-NIPS
figure-Segmentor-PeakSeg.png: figure-Segmentor-PeakSeg.R PeakSeg4samples.RData chr11coverage.RData
	R --no-save < $<

figure-joint.tex: figure-joint.R
	R --no-save < $<
figure-reads.png: figure-reads.R
	R --no-save < $<
figure-Segmentor.png: figure-Segmentor.R
	R --no-save < $<
chr11coverage.RData: chr11coverage.R
	R --no-save < $<
figure-Segmentor-coverage.png: figure-Segmentor-coverage.R chr11coverage.RData
	R --no-save < $<
figure-input-coverage.png: figure-input-coverage.R chr11coverage.RData
	R --no-save < $<
figure-normalized-counts.png: figure-normalized-counts.R chr11coverage.RData signal.mat.RData
	R --no-save < $<
figure-poisson-loss.pdf: figure-poisson-loss.R
	R --no-save < $<
figure-Segmentor-nopeaks.png: figure-Segmentor-nopeaks.R chr11coverage.RData
	R --no-save < $<
figure-pruned-1.pdf: figure-pruned.R chr11coverage.RData
	R --no-save < $<
figure-PeakSeg.png: figure-PeakSeg.R chr11coverage.RData PeakSeg4samples.RData
	R --no-save < $<
PeakSeg.one.chunk.RData: PeakSeg.one.chunk.R chr11coverage.RData
	R --no-save < $<
PeakSeg4samples.RData: PeakSeg4samples.R chr11coverage.RData
	R --no-save < $<
figure-PeakSeg-one-chunk.png: figure-PeakSeg-one-chunk.R PeakSeg.one.chunk.RData
	R --no-save < $<
figure-PeakSeg-4samples.png: figure-PeakSeg-4samples.R PeakSeg4samples.RData
	R --no-save < $<
figure-PeakSeg-one-chunk-clusters.pdf: figure-PeakSeg-one-chunk-clusters.R PeakSeg.one.chunk.RData
	R --no-save < $<
figure-PeakSeg-first-last.png: figure-PeakSeg-first-last.R 
	R --no-save < $<
dp.timings.RData: dp.timings.R
	R --no-save < $<
figure-dp-timings.pdf: figure-dp-timings.R dp.timings.RData Segmentor.timings.RData
	R --no-save < $<
Segmentor.timings.RData: Segmentor.timings.R
	R --no-save < $<
figure-PeakSeg-one-chunk-clusters-error.png: figure-PeakSeg-one-chunk-clusters-error.R  PeakSeg.one.chunk.RData
	R --no-save < $<
figure-constraint.tex: figure-constraint.R
	R --no-save < $<
dp.peaks.RData: dp.peaks.R dp.timings.RData
	R --no-save < $<
dp.peaks.error.RData: dp.peaks.error.R dp.peaks.RData
	R --no-save < $<
dp.peaks.train.RData: dp.peaks.train.R dp.peaks.error.RData
	R --no-save < $<
figure-dp-peaks-train-hmcan.pdf: figure-dp-peaks-train.R dp.peaks.train.RData
	R --no-save < $<
figure-PeakSeg-4samples-intervals.pdf: figure-PeakSeg-4samples-intervals.R PeakSeg4samples.RData
	R --no-save < $<
figure-PeakSeg-H3K36me3-chunk1-1.png: figure-PeakSeg-H3K36me3-chunk.R dp.peaks.train.RData
	R --no-save < $<
figure-PeakSeg-4samples-background.png: figure-PeakSeg-4samples-background.R PeakSeg4samples.RData
	R --no-save < $<
dp.peaks.matrices.RData: dp.peaks.matrices.R dp.peaks.error.RData
	R --no-save < $<
dp.peaks.baseline.RData: dp.peaks.baseline.R dp.peaks.sets.RData
	R --no-save < $<
dp.peaks.sets.RData: dp.peaks.sets.R dp.peaks.matrices.RData
	R --no-save < $<
figure-dp-peaks-baseline.pdf: figure-dp-peaks-baseline.R dp.peaks.baseline.RData
	R --no-save < $<
dp.peaks.optimal.RData: dp.peaks.optimal.R dp.peaks.matrices.RData
	R --no-save < $<
dp.peaks.intervals.RData: dp.peaks.intervals.R dp.peaks.optimal.RData
	R --no-save < $<
dp.peaks.regression.RData: dp.peaks.regression.R dp.peaks.intervals.RData
	R --no-save < $<
figure-dp-peaks-intervals.pdf: figure-dp-peaks-intervals.R dp.peaks.intervals.RData
	R --no-save < $<
table-dp-peaks-regression.tex: table-dp-peaks-regression.R dp.peaks.regression.RData dp.peaks.baseline.RData
	R --no-save < $<
## NIPS workshop paper
## Interactive viz
dp.peaks.interactive.RData: dp.peaks.interactive.R table-dp-peaks-regression.tex
	R --no-save < $<
figure-dp-peaks-interactive/index.html: figure-dp-peaks-interactive.R dp.peaks.interactive.RData
	R --no-save < $<
chr11first.RData: chr11first.R
	R --no-save < $<
figure-dp-peaks-extrapolation.pdf: figure-dp-peaks-extrapolation.R
	R --no-save < $<
## heuristic on whole sample
nogaps.RData: nogaps.R
	R --no-save < $<
figure-nogaps.pdf: figure-nogaps.R nogaps.RData
	R --no-save < $<
mappable.RData: mappable.R
	R --no-save < $<
figure-mappable.png: figure-mappable.R mappable.RData
	R --no-save < $<
figure-nogaps-timings.pdf: figure-nogaps-timings.R nogaps.timings.RData
	R --no-save < $<
nogaps.timings.RData: nogaps.timings.R nogaps.RData
	R --no-save < $<
hg19.no.visual.gaps.timings.RData: hg19.no.visual.gaps.timings.R hg19.no.visual.gaps.RData
	R --no-save < $<
hg19.no.visual.gaps.RData: hg19.no.visual.gaps.R
	R --no-save < $<
## Handout
HOCKING-PeakSeg-handout.pdf: HOCKING-PeakSeg-handout.tex
	pdflatex HOCKING-PeakSeg-handout
	bibtex HOCKING-PeakSeg-handout
	pdflatex HOCKING-PeakSeg-handout
	pdflatex HOCKING-PeakSeg-handout
## heuristic on benchmark
figure-heuristic.png: figure-heuristic.R
	R --no-save < $<
heuristic.timings.RData: heuristic.timings.R
	R --no-save < $<
heuristic.peaks.RData: heuristic.peaks.R heuristic.timings.RData
	R --no-save < $<
heuristic.error.RData: heuristic.error.R heuristic.peaks.RData
	R --no-save < $<
heuristic.error.train.RData: heuristic.error.train.R heuristic.error.RData dp.peaks.train.RData
	R --no-save < $<
table-heuristic-error-train.tex: table-heuristic-error-train.R heuristic.error.train.RData
	R --no-save < $<
figure-heuristic-timings.pdf: figure-heuristic-timings.R
	R --no-save < $<
