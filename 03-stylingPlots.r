#!/bin/env Rscript
library(cowplot)
library(data.table)
library(plyr)
library(ggplot2)
library(this.path)
library(RColorBrewer)
library(scales)
library(sqldf)
setwd(this.dir())
threadScale <- fread('data/threadscale.csv')
threadScale[, c("query", "parallel", "method") := tstrsplit(threadScale$name, ' ')]
threadScale[, parallel := as.numeric(sub("parallel", "", threadScale$parallel))]
threadScale[, method := revalue(threadScale$method, c("D" = "separate", "H" = "memoizing", "R" = "eager"))]
threadScale[, method := factor(threadScale$method, levels = c("separate", "memoizing", "eager"))]
q3 <- threadScale[query == 'Q3']

# The example plots from 02-plotting.r
single <- ggplot(q3, aes(x = parallel, y = 1 / execution_time_median, color = method, shape = method)) +
  geom_point() +
  geom_smooth(se = FALSE)

# The plot has margins by default, but when embedding, we almost always want to control that from the
# embedding environment
theme_condensed <- function() { theme(plot.margin = unit(c(0, 0, 0, 0), "mm"), legend.margin = margin(0, 0, 0, 0, "cm")) }

single +
  theme_condensed()

# The default gray background is OK-ish for displays, but looks questionable on paper. The cowplot
# package has nice defaults with more white space. "hgrid" is nice when you plot your metric on 
# the y-axis. The help pages list further options. Add the cowplot theme before your theme 
# customizations, since it overrides everything else.
single <- single +
  theme_minimal_hgrid() +
  panel_border() +
  theme_condensed()
single

# The legend is also an important part of your plot, think about where to position it!
no_legend <- function() { theme(legend.position = "none") }
legend_position <- function(x, y) { theme(legend.position = c(x, y)) }

# No legend allows you to share the legend between plots
single +
  no_legend()
# Positioning the legend within the plot allow the plot to expand
single <- single +
  legend_position(.7, .2)
single

# ggplot adds a generous 5% distance between axis and its last point. Especially baselines
# sometimes look weird this way, so, e.g., start your axis at 0.
single +
  scale_y_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(y = 0) +
  scale_x_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(x = 0)

# For numbers between 0 and 1, try using percentage labels
single +
  scale_y_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(y = 0) +
  scale_x_continuous(expand = expansion(mult = c(0, .02)), labels = scales::percent) +
  expand_limits(x = 0)

# Or if you would rather use an SI-prefixed unit (e.g., ms), you can also scale them
single +
  scale_y_continuous(expand = expansion(mult = c(0, .02)), labels = unit_format(unit = "", scale = 1e3)) +
  expand_limits(y = 0) +
  scale_x_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(x = 0)

# In case you have too few axis breaks, you can also increase their number
single +
  scale_y_continuous(expand = expansion(mult = c(0, .02)), breaks = scales::breaks_extended(10)) +
  expand_limits(y = 0) +
  scale_x_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(x = 0)

# Writing custom labeling functions also also always a possibility.
# Use with: scale_x_continuous(labels = si_labels)
si_labels <- function(y) {
  lapply(y, function(x) {
    if (is.na(x)) return('')
    if (x < 1000)
      return(paste(x))
    else if (x < 1000000)
      return(paste(x / 1000, "K", sep = ''))
    else if (x < 1000000000)
      return(paste(x / 1000000, "M", sep = ''))
    else
      return(paste(x / 1000000000, "G", sep = ''))
  })
}
# With custom labeling, you can also use latex for log scales
log10_labels_tex <- function(y) {
  lapply(y, function(x) {
    if (is.na(x)) return('')
    i <- abs(log10(x))
    if (i == 0) return(1)
    return(paste("$10^", i, "$", sep = ''))
  })
}

# When you customize the labels, always make sure to also update the axis labels.
# This of course heavily depends on what you've measured!
single <- single +
  scale_y_continuous(expand = expansion(mult = c(0, .02)), labels = unit_format(unit = "", scale = 1e3)) +
  expand_limits(y = 0) +
  scale_x_continuous(expand = expansion(mult = c(0, .02))) +
  expand_limits(x = 0) +
  labs(y = "Throughput (runs per second)")

# Lastly, consistent and good colors are nice to have. Colorbrewer https://colorbrewer2.org/ is a
# good source for high quality color themes, and available directly for ggplot with RColorBrewer
single +
  scale_color_brewer(type = "qual", palette = 6) +
  scale_fill_brewer(type = "qual", palette = 6)
