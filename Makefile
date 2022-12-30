# Default rule to build an integrated PDF
all: out/05-integrated.pdf

# Build rule using latexmk
BUILD_TEX = latexmk -pdf -interaction=nonstopmode -outdir=out $<

# A list of generated files containing the exported plots
generated_files :=	out/multiDirect.pdf	\
			out/multiTikzDevice.tikz\
			out/q3Direct.pdf	\
			out/q3TikzDevice.tikz

# A list of PDFs that we want to include in the integrated PDF
all_figures :=	out/multiDirect.pdf	\
		out/multiTikzDevice.pdf	\
		out/q3Direct.pdf	\
		out/q3TikzDevice.pdf

# Build rule for the integrated PDF. Note that it depends on all generated figures as PDFs
out/05-integrated.pdf: 05-integrated.tex $(all_figures)
	$(BUILD_TEX)

# Build rules for the TikZ exported figures.
# You could also build them directly with your R script, but I like to keep the tikz files checked
# in, so building just the paper PDF does not require a full R installation.
out/multiTikzDevice.pdf: out/multiTikzDevice.tikz
	$(BUILD_TEX)
out/q3TikzDevice.pdf: out/q3TikzDevice.tikz
	$(BUILD_TEX)

# Build rule that re-runs your R script if you change something in there
$(generated_files): 04-exportingPlots.r
	./04-exportingPlots.r

