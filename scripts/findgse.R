if (!require("pacman")) install.packages("pacman", "~/.conda/envs/assembly_pipeline/lib/R/library", repo="http://cran.rstudio.com/")

library(pacman)

pacman::p_load("pracma", "fGarch")
pacman::p_load_gh("schneebergerlab/findGSE")

findGSE(histo=snakemake@input[[1]], sizek=21, outdir=snakemake@params[["outdir"]])
