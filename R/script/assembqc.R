# Assembly QC 

# ---- Load Packages ----
library("tidyverse")
library("tidylog")

# ---- Load Tables ----
quast <- read.delim("assembqc/report.tsv", sep = "\t")
checkm <- read.delim("assembqc/checkm.tsv", sep = "\t") 
ss <- read.delim("assembqc/enteroseqsero_summary.tsv", sep = "\t")
sr <- read.delim("assembqc/sistr_output.txt", sep = "\t")
st <- read.delim("assembqc/mlst.tsv", sep = "\t", header = FALSE) 


# ---- Format to combine ----
# CheckM
colnames(checkm)

checkm <- checkm %>%
  mutate(ID=str_split_fixed(Bin.Id, "\\_", 2)[,1]) %>% # cut _assembly off name
  select(ID, Completeness, Contamination, Strain.heterogeneity)


# QUAST 
colnames(quast)
quast2<- data.table::transpose(quast)
quast2 <- as.data.frame(apply(quast2, 2, as.numeric))
colnames(quast2) <- quast$Assembly
quast2$ID <- colnames(quast)
quast2$ID <- str_remove_all(quast2$ID, "_assembly")
rownames(quast2) <- quast2$ID
quast2 <- quast2[-1,]

# SISTR
colnames(sr)

sr2 <- sr %>%
  mutate(ID=str_split_fixed(genome, "\\_", 2)[,1]) %>% # cut _assembly off name
  select(ID, o_antigen, h1, serogroup, serovar)


# SeqSero2 
colnames(ss)

ss2 <- ss %>%
  mutate(ID=Sample.name) %>%
  filter(!str_detect(ID, "alleles")) %>%
  select(ID, Predicted.antigenic.profile, Predicted.serotype)

# MLST
colnames(st)

st2 <- st %>%
  mutate(ID=str_split_fixed(V1, "\\_", 2)[,1]) %>%
  mutate(ST=V3) %>%
  select(ID, ST)

all <- checkm %>%
  inner_join(quast2, by = "ID") %>%
  inner_join(sr2, by = "ID") %>%
  inner_join(ss2, by = "ID") %>%
  full_join(st2, by = "ID")

#save this 
write.table(all, "assembqc/allcombined.txt", sep = "\t")

# ----- Filter : Sero -----

# First by serotype
table(all$serovar)
table(all$Predicted.serotype) # all dublin

all %>%
  group_by(ST) %>% # check ST
  summarise(count=n()) 

# final dataset

# ----  Filter: Assemb Stats ----

summary(all %>%
          select(Completeness, Contamination, Strain.heterogeneity)) # these are all fine

summary(all %>%
          select(`Total length (>= 0 bp)`, `GC (%)`, N50, `# contigs (>= 0 bp)`)) # these are all fine

# --- add ST to metadata 
met <- read.delim("meta/meta_v1.tsv", sep = "\t")
met2 <- met %>%
  filter(sra_accession %in% all$ID) %>%
  inner_join(all %>%
               mutate(sra_accession=ID) %>%
               select(sra_accession, ST), by = "sra_accession")

write.table(met2, "meta/meta_v2.tsv", sep = "\t")