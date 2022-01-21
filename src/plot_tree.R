
# Plot RAxML tree

library(ggplot2)
library(ggtree)
library(ggfortify)
library(magrittr)
library(treeio)

# Tree from RAxML output: best of 20 trees with 100 bootstrap replicates
tree <- read.raxml("RAxML/RAxML_bipartitionsBranchLabels.T1")

# Check tip labels
get.tree(tree)$tip.label

# Remove "_" from strain names
# Only plot bootstrap values <100
ggtree(tree) + 
  geom_tiplab(aes(label = label %>% gsub("_", " ", .) %>% gsub("pv", "pv.", .)),
              size = 2.5, parse = F) +
  geom_text(aes(label = ifelse(bootstrap < 100, bootstrap, "")), 
            size = 2.5, position = position_nudge(x = -0.001)) +
  geom_treescale(x = 0, y = -1) +
  xlim(0, 0.1) +
  ggsave(path = "RAxML/", filename = "amygdali_tree.pdf", device = "pdf", dpi = 300)

