if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("DESeq2")

subgem <- function(gem, anot, group ){
  datalist = list()
  subanot = subset(anot, Comparison == group)
  for (id in subanot$Sample) {
	ind = which(colnames(gem) == id)
	genes = gem[0]
	exp = gem[,ind]
	datalist[[id]] <- exp
  }
  subcounts = cbind(genes, datalist)
  return(subcounts)
}

subanot <- function(anot, group){
  datalist = list()
  print(str(group))
  subanot = subset(anot, Comparison == group)
  print(str(subanot))
  return(subanot)
}
library(DESeq2)
run_deseq <- function(counts, annotation){
  dds <- DESeqDataSetFromMatrix(countData = counts,
                            	colData = annotation,
             	               design = ~ Group)
 #Filter and normalize genes with low total counts across all samples
  dds <- dds[rowSums(counts(dds)) >= 50,]
  dds <- DESeq(dds)
  norm = fpm(dds)
#Sort the columns in the FPM data frame
  conditionA = which(annotation[2] == "BLCA_GTEX")
  conditionB = which(annotation[2] == "BLCA_TCGA")
  norm = subset(norm, select=c(conditionA, conditionB))
  print(str(norm))
#Retrieve the results
  res <- results(dds, contrast=c("Group", "BLCA_GTEX", "BLCA_TCGA"))
  print(summary(res))
  res <- cbind(res, norm) # Note: Could add FPM values to results for better visualization?
  resultsNames(dds)
  return(res)
}
main <- function(countfile, anotfile, outfile){
  outname = outfile
  counts = read.delim(countfile, sep=',', header=TRUE, row.names='Hugo_Symbol')
  samples = read.delim(anotfile, sep=',', row.names = NULL, check.names=FALSE)
  groups = unique(samples$Comparison)
  for (t in groups){
	subcounts = subgem(counts, samples, t)
	subannotation = subanot(samples, t)
	results = run_deseq(subcounts, subannotation)
	#Filter and sort results table
	f_results = subset(results, padj < 0.05)
	o_results = f_results[order(f_results$padj),]
	write.csv(o_results, outname, row.names = TRUE)
  }
  return(results)
}
main('bladder-gtex-tcga-clean.csv', 'bladder-gtex-tcga.comparison.csv', 'output-bladder-gtex-tcga-degs.csv')
