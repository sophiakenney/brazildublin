# Tree viz 
library(ggtree)
library(ape)
library(ggpubr)
library(tidyverse)
library(ggtreeExtra)
library(paletteer)

# --- Load Tree ----
tree <- ape::read.tree("phylo/iq1.treefile")
cophenetic_matrix <- cophenetic(tree)
met <- read.delim("query/meta_v2.tsv", sep = "\t")
row.names(met) <- met$sra_accession

#plot inner tree
ggtree(tree, layout = "circular", branch.length = "none")  

ggtree(tree, layout = "circular", branch.length = "none")  %<+% met +
  geom_tippoint(aes(color = country))+
  guides(color = guide_legend(ncol = 1))

# Plot tree for paper
p<-ggtree(tree)

met<- met %>%
  mutate(host_assoc = str_to_sentence(host_assoc))

p %<+% met +
  geom_tippoint(aes(color = country, shape = host_assoc), size = 4, alpha=0.5)+
  scale_color_paletteer_d("MoMAColors::Klein")+
  guides(color = guide_legend(ncol = 1, title = "Country"),
         shape = guide_legend(title = "Host")) +
  ylim(0,201)+
  geom_treescale( fontsize=3, linesize=1, offset=1)


# different formats for the article

p2 <-ggtree(tree, layout = "circular", branch.length = "none")

p2 %<+% met +
  geom_tippoint(aes(color = country, shape = host_assoc), size = 4, alpha=0.5)+
  scale_color_paletteer_d("MoMAColors::Klein")+
  guides(color = guide_legend(ncol = 1, title = "Country"),
         shape = guide_legend(title = "Host")) +
  ylim(0,201)


p3 <-ggtree(tree, layout = "circular") 
p3 %<+% met +
  geom_tippoint(aes(color = country, shape = host_assoc), size = 4, alpha=0.5)+
  scale_color_paletteer_d("MoMAColors::Klein")+
  guides(color = guide_legend(ncol = 1, title = "Country"),
         shape = guide_legend(title = "Host")) +
  ylim(0,201)+
  geom_treescale( fontsize=3, linesize=1, offset=1)

