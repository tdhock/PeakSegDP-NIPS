HOCKING-RIGAILL-chip-seq-NIPS.pdf: HOCKING-RIGAILL-chip-seq-NIPS.tex refs.bib figure-Segmentor-PeakSeg.png figure-dp-peaks-regression-dots.pdf
	rm -f *.aux *.bbl
	pdflatex HOCKING-RIGAILL-chip-seq-NIPS
	bibtex HOCKING-RIGAILL-chip-seq-NIPS
	pdflatex HOCKING-RIGAILL-chip-seq-NIPS
	pdflatex HOCKING-RIGAILL-chip-seq-NIPS

figure-Segmentor-PeakSeg.png: figure-Segmentor-PeakSeg.R
	R --no-save < $<
figure-dp-peaks-regression-dots.pdf: figure-dp-peaks-regression-dots.R dp.peaks.regression.RData dp.peaks.baseline.RData
	R --no-save < $<

dp.peaks.baseline.RData: dp.peaks.baseline.R dp.peaks.sets.RData
	R --no-save < $<
dp.peaks.sets.RData: dp.peaks.sets.R dp.peaks.matrices.RData
	R --no-save < $<
dp.peaks.matrices.RData: dp.peaks.matrices.R dp.peaks.error.RData
	R --no-save < $<
dp.peaks.error.RData: dp.peaks.error.R dp.peaks.RData
	R --no-save < $<
dp.peaks.RData: dp.peaks.R dp.timings.RData
	R --no-save < $<
dp.timings.RData: dp.timings.R
	R --no-save < $<
dp.peaks.optimal.RData: dp.peaks.optimal.R dp.peaks.matrices.RData
	R --no-save < $<
dp.peaks.intervals.RData: dp.peaks.intervals.R dp.peaks.optimal.RData
	R --no-save < $<
dp.peaks.regression.RData: dp.peaks.regression.R dp.peaks.intervals.RData
	R --no-save < $<
