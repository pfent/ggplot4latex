#!/bin/env Rscript
library(this.path)

# Change the working directory to the script's location
setwd(this.dir())

files <- list.files()
cat("Now you can use project relative references: ", files[1], "\n")

# I like to keep my scripts in a separate 'scripts/' directory, so cd to the parent dir instead
setwd(paste0(this.dir(), "/.."))
