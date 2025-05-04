# Differentially Expressed Genes (DEG) Analysis and Visualization
Matt Harrington, Clemson University

2025-04-04

## Purpose
These scripts will identify differentially expressed genes between normal tissue (GTEx) and tumor tissue (TCGA) samples from gene expression matrices, produce a DEG analysis from these samples, and produce a volcano plot identifying over- and under-expressed genes from the DEG analysis.

## Usage
Initial GEMs are downloaded from [Wang et al (2018)](https://doi.org/10.1038/sdata.2018.61) and merged using [MergeGEM](https://github.com/feltus/mergegem.git).

Bladder cancer is examined in this script, but the tissue of origin can be chosen from any data available in the Wang et al publication to remain functional with these scripts.
