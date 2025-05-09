# DEG Volcano Plot in R

library(ggplot2)
library(dplyr)
library(readr)
library(ggrepel)

# Read DESeq2 results file from create-deg.R
deseq_results <- read_csv("output-bladder-gtex-tcga-degs.csv")

# Name first column of GEM to "gene_name"
names(deseq_results)[1] <- "gene_name"

# Create a new column to categorize genes
deseq_results <- deseq_results %>%
  mutate(
    significance = case_when(
      padj < 0.05 & log2FoldChange < -1 ~ "Down-regulated",
      padj < 0.05 & log2FoldChange > 1 ~ "Up-regulated",
      TRUE ~ "Not significant"
    )
  )

# Create the volcano plot
volcano_plot <- ggplot(deseq_results, aes(x = log2FoldChange, y = -log10(padj), 
                                         color = significance)) +
  geom_point(alpha = 0.7, size = 1.5) +
  scale_color_manual(values = c("Down-regulated" = "blue", 
                               "Up-regulated" = "red", 
                               "Not significant" = "gray")) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "gray50") +
  labs(
    title = "RNAseq Expression in Tumor vs. Normal Bladder Tissue",
    subtitle = "TCGA vs. GTEx samples",
    x = "Log2 Fold Change",
    y = "-Log10 Adjusted P-value",
    color = "Significance"
  ) +
  theme_bw() +
  theme(
    legend.position = "right",
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12, face = "bold")
  )

# Check how many genes meet over/underexpression criteria
overexpressed_count <- deseq_results %>%
  filter(padj < 0.05 & log2FoldChange > 1) %>%
  nrow()

underexpressed_count <- deseq_results %>%
  filter(padj < 0.05 & log2FoldChange < -1) %>%
  nrow()

# Print counts to console
print(paste("Number of over-expressed genes:", overexpressed_count))
print(paste("Number of under-expressed genes:", underexpressed_count))

# Identify top 10 most over-expressed genes (highest positive log2FoldChange)
# If fewer than 10 genes meeting the criteria, relax the fold change threshold
if(overexpressed_count >= 10) {
  top_10_overexpressed <- deseq_results %>%
    filter(padj < 0.05 & log2FoldChange > 1) %>%
    arrange(desc(log2FoldChange)) %>%
    head(10)
} else {
  # Relax the fold change threshold to get exactly 10 genes
  top_10_overexpressed <- deseq_results %>%
    filter(padj < 0.05 & log2FoldChange > 0) %>%  # Changed from log2FoldChange > 1
    arrange(desc(log2FoldChange)) %>%
    head(10)
}

# Identify top 10 most under-expressed genes (lowest negative log2FoldChange)
# Same for under-expressed genes
if(underexpressed_count >= 10) {
  top_10_underexpressed <- deseq_results %>%
    filter(padj < 0.05 & log2FoldChange < -1) %>%
    arrange(log2FoldChange) %>%
    head(10)
} else {
  # Relax the fold change threshold to get exactly 10 genes
  top_10_underexpressed <- deseq_results %>%
    filter(padj < 0.05 & log2FoldChange < 0) %>%  # Changed from log2FoldChange < -1
    arrange(log2FoldChange) %>%
    head(10)
}

# Print the number of genes selected for labeling
print(paste("Number of over-expressed genes selected:", nrow(top_10_overexpressed)))
print(paste("Number of under-expressed genes selected:", nrow(top_10_underexpressed)))

# Combine the two sets of genes
top_genes_to_label <- bind_rows(top_10_overexpressed, top_10_underexpressed)

# Add gene names for only these top genes
volcano_plot <- volcano_plot +
  geom_text_repel(data = top_genes_to_label, 
            aes(label = gene_name),
            size = 3,
            box.padding = 0.5,
            point.padding = 0.3,
            max.overlaps = 30,
            segment.color = "black",
            color = "black",
            show.legend = FALSE)

# Display the plot
print(volcano_plot)

# Save the plot to a file
ggsave("tcga-vs-gtex-blca-deg-plot.png", volcano_plot, width = 10, height = 8, dpi = 300)
