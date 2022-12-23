#!/bin/env Rscript
library(data.table)
library(plyr)
library(ggplot2)
library(this.path)
library(sqldf)
setwd(this.dir())
threadScale <- fread('data/threadscale.csv')
threadScale[, c("query", "parallel", "method") := tstrsplit(threadScale$name, ' ')]
threadScale[, parallel := as.numeric(sub("parallel", "", threadScale$parallel))]
threadScale[, method := revalue(threadScale$method, c("D" = "separate", "H" = "memoizing", "R" = "eager"))]

# Exploring data by plotting it works best in RStudio. Take the data, where we want to
# see the impact of parallelism on performance.
# For starters, plot your variable (what you change) to the x axis, and your metric
# on the y axis. For visualization, plotting points never hurts. 
ggplot(threadScale, aes(x = parallel, y = execution_time_median)) +
  geom_point()

# Wow, that's lots of points. We see a trend here, but we can't say something concrete.
# Let's see if we can reduce the number of points by focusing on a specific measurement
q3 <- threadScale[query == 'Q3']
ggplot(q3, aes(x = parallel, y = execution_time_median)) +
  geom_point()

# Better! Now let's add some distinction to the rows of points
ggplot(q3, aes(x = parallel, y = execution_time_median, color = method)) +
  geom_point()

# Now we're talking. But we still can't see the difference between the best methods.
# If your best approaches are cramped down at the x-axis, try inverting y. This is now 
# technically a different metric, so you need to come up with a new name!
ggplot(q3, aes(x = parallel, y = 1 / execution_time_median, color = method)) +
  geom_point()

# To round out the plot, let's add a trend line for the measurements
ggplot(q3, aes(x = parallel, y = 1 / execution_time_median, color = method)) +
  geom_point() +
  geom_smooth(se = FALSE)

# Double encoding color and shapes helps distinguishing the methods even more
ggplot(q3, aes(x = parallel, y = 1 / execution_time_median, color = method, shape = method)) +
  geom_point() +
  geom_smooth(se = FALSE)

# In case the legend ordering is weird, you can explicitly define the factors in an order you like
q3[, method := factor(q3$method, levels = c("separate", "memoizing", "eager"))]
ggplot(q3, aes(x = parallel, y = 1 / execution_time_median, color = method, shape = method)) +
  geom_point() +
  geom_smooth(se = FALSE)

# Now let's apply that not only to one query, but for all queries we have.
# Fitting that into one plot is hard, but we can generate lots of plots quickly with facets.
threadScale[, method := factor(threadScale$method, levels = c("separate", "memoizing", "eager"))]
ggplot(threadScale, aes(x = parallel, y = 1 / execution_time_median, color = method, shape = method)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_wrap(. ~ query)

# Facets allow comparisons between different queries, since they share the same axis.
# If we don't need the comparison, freeing some axis does allow much more detail per facet.
ggplot(threadScale, aes(x = parallel, y = 1 / execution_time_median, color = method, shape = method)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_wrap(. ~ query, scales = 'free_y')
