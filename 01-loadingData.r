#!/bin/env Rscript
library(data.table)
library(plyr)
library(this.path)
library(sqldf)
setwd(this.dir())

# Read the data from a CSV measurements file. CSV is easy to generate, but keep
# one measurement per row. Don't try to normalize that table, just repeat all
# data points each row.
threadScale <- fread('data/threadscale.csv')

# Extract some dimensions from the name. It's better to write them out separated,
# but sometimes that doesn't work out...
threadScale[, c("query", "parallel", "method") := tstrsplit(threadScale$name, ' ')]

# You can also rename some columns to give them more descriptive names
threadScale[, method := revalue(threadScale$method, c("D" = "separate", "H" = "memoizing", "R" = "eager"))]

# Nothing beats SQL to get some aggregates results
sqldf('
SELECT DISTINCT query, method
FROM threadScale
')
