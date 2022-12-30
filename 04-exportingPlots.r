#!/bin/env Rscript
library(cowplot)
library(data.table)
library(plyr)
library(ggplot2)
library(this.path)
library(RColorBrewer)
library(scales)
library(sqldf)
library(tikzDevice)
setwd(this.dir())
threadScale <- fread('data/threadscale.csv')
threadScale[, c("query", "parallel", "method") := tstrsplit(threadScale$name, ' ')]
threadScale[, parallel := as.numeric(sub("parallel", "", threadScale$parallel))]
threadScale[, method := revalue(threadScale$method, c("D" = "separate", "H" = "memoizing", "R" = "eager"))]
threadScale[, method := factor(threadScale$method, levels = c("separate", "memoizing", "eager"))]
q3 <- threadScale[query == 'Q3']

# Some helpers
no_legend <- function() { theme(legend.position = "none") }
legend_bottom <- function() { theme(legend.position = "bottom") }
legend_position <- function(x, y) { theme(legend.position = c(x, y)) }
theme_condensed <- function() { theme(plot.margin = unit(c(0, 0, 0, 0), "mm"), legend.margin = margin(0, 0, 0, 0, "cm")) }

# The styled plot from 03-stylingPlots.r
single <- ggplot(q3, aes(x = parallel, y = 1 / execution_time_median, color = method, shape = method)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  scale_y_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(y = 0) +
  labs(y = "Throughput (1K runs per second)") +
  scale_x_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(x = 0) +
  theme_minimal_hgrid() +
  panel_border() +
  theme_condensed() +
  scale_color_brewer(type = "qual", palette = 6) +
  scale_fill_brewer(type = "qual", palette = 6) +
  legend_position(.7, .2)

# Export the plot directly as PDF. The width / height here is a good default for a standard
# single-column figure in a double-column paper.
ggsave2("out/q3Direct.pdf", plot = single, width = 3.2, height = 2.0)

# The text in the exported PDF is unfortunately way too big. You can use the following theme to
# get the font in a sensible size. However, always applying it makes viewing it in RStudio bad
theme_tex <- function() { theme(axis.text = element_text(size = 6), axis.title = element_text(size = 8),
                                legend.text = element_text(size = 6), legend.title = element_text(size = 8),
                                legend.key.size = unit(4, "mm"), legend.box.spacing = unit(1, "mm"),
                                strip.text = element_text(size = 8),
                                panel.spacing.x = unit(1, "mm"), panel.spacing.y = unit(0, "mm")) }
ggsave2("out/q3Direct.pdf", plot = single + theme_tex(), width = 3.2, height = 2.0)

# Since ggsave() directly produces a PDF, it doesn't support latex fonts or any latex commands.
# tikzDevice allows to export plots as TikZ graphics that behave more like latex figures.
tikz("out/q3TikzDevice.tikz", standAlone = TRUE, width = 3.2, height = 2.0)
single + theme_tex()
dev.off()

# However, this needs another build step to produce a PDF you can include
system("latexmk -pdf -interaction=nonstopmode -outdir=out out/q3TikzDevice.tikz")

# The second plot with facets works similar
multi <- ggplot(threadScale, aes(x = parallel, y = 1 / execution_time_median, color = method, shape = method)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_wrap(. ~ query, scales = 'free_y') +
  scale_y_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(y = 0) +
  labs(y = "Throughput (1K runs per second)") +
  scale_x_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(x = 0) +
  theme_minimal_hgrid() +
  panel_border() +
  theme_condensed() +
  scale_color_brewer(type = "qual", palette = 6) +
  scale_fill_brewer(type = "qual", palette = 6) +
  legend_bottom()

# But we need a larger height, so the plot is legible
ggsave2("out/multiDirect.pdf", plot = multi + theme_tex(), width = 3.2, height = 2.8)
tikz("out/multiTikzDevice.tikz", standAlone = TRUE, width = 3.2, height = 2.8)
multi + theme_tex()
dev.off()

# system("latexmk -pdf -interaction=nonstopmode -outdir=out out/multiTikzDevice.tikz")
