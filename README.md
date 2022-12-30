# How to use ggplot2 for paper figures

These are some recipes I collected to convert data into plots that fit into a scientific paper.
My workflow is to first collect some measurements as CSV files, then quickly visualize them using ggplot2.
I like ggplot, because it allows to efficiently iterate on plot ideas in a declarative way.
The downside is that the default visualizations look nice on a screen, but need a bit of work to include into a LaTeX
document.
If you follow the recipes in this repo, you should be able to explore data and measurements interactively in RStudio,
before you export them to TikZ figures that you can include in a LaTeX writeup.

## Setting up R
R is a quirky programming language:
It is vector oriented, so most operations operate on a whole column of a table.
For example, a `* 2` on a columns doubles all elements in that column resulting in another column.
Still, R is dynamically typed.
Mismatching values will often then result in `N/A` values, and some operations even drop them altogether.

The dynamic nature also enables some very powerful libraries that completely change the way we use R.
ggplot is the most famous, providing a very nice way to create plots, and sqldf provides an SQL interface to your local
variables
You can install all packages we're using in this repo with the following command:
```sh
R --vanilla --interactive < <(echo "install.packages(c('data.table', 'cowplot', 'plyr', 'ggplot2', 'this.path', 'RColorBrewer', 'sqldf'))")
```
[RStudio](https://posit.co/download/rstudio-desktop/) is an additional tool that let's you interactively see your plots,
before you wrap them up as Rscript versions to programmatically generate PDF plots.

## Step by step instructions
0. [00-workingDir.r](./00-workingDir.r):  
   Set up a working dir relative to the R script location
1. [01-loadingData.r](./01-loadingData.r):  
   Load data from a CSV file and run some simple analysis
2. [02-plotting.r](./02-plotting.r):  
   Start plotting your data
3. [03-stylingPlots.r](./03-stylingPlots.r):  
   Style the plot for printing
4. [04-exportingPlots.r](./04-exportingPlots.r):  
   Exporting the plot to PDF and TikZ
5. [05-integrated.tex](./05-integrated.tex):  
   Tying things together with a [Makefile](./Makefile)
