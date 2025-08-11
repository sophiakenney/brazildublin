# Filter NCBI Query 

# --- Load Packages ---
library(tidyverse)
library(tidylog)
library(ggpubr)

setwd("./R/")

# ---- load tables ----
usa <- read.delim("query/finalset_meta.tsv", sep = "\t") # sourced from https://github.com/sophiakenney/compare_sdublin.git/R/meta
query <- read.delim("query/query.tsv", sep = "\t")

# ----- Check New Query ----

# check sample types and host 
query %>%
  group_by(Host) %>%
  count()


ggplot(query %>%
         group_by(Host) %>%
         count(Isolation.source), aes(y=Isolation.source, x=n))+
  geom_bar(stat = "identity")+
  theme_classic() +
  facet_wrap(~Host, scales = "free")

ggplot(query %>%
         group_by(Location) %>%
         count(), aes(y=Location, x=n))+
  geom_bar(stat = "identity")+
  theme_classic()

# subset locations for n>30
ggplot(query %>%
         group_by(Location) %>%
         mutate(count=n()) %>%
         ungroup() %>%
         filter(count > 30), aes(y=Location, fill=Host))+
  geom_bar()+
  theme_classic()

ggplot(query %>%
         group_by(Location) %>%
         mutate(count=n()) %>%
         ungroup() %>%
         filter(count < 30), aes(y=Location, fill=Host))+
  geom_bar()+
  theme_classic()


# ---- Subset strains countries with >30 strains (except for Brazilian) ----
# all human but UK strains - to filter
query %>%
  filter(Host == "Homo sapiens") %>%
  filter(!str_detect(Location, "United"))


n30 <- query %>%
  filter(str_detect(Location, "United") |
           str_detect(Location, "Germany") |
           str_detect(Location, "Denmark")) %>%
  rbind(query %>%
          filter(Host != "Homo sapiens" & str_detect(Location, "Canada"))) #Include Canada - cattle sourced only >30


n30 %>%
  mutate(year = str_split_fixed(Collection.date, "-", 3)[,1]) %>%
  group_by(Location, year) %>%
  count()

n30 <- n30 %>%
  mutate(year = str_split_fixed(Collection.date, "-", 3)[,1])

# subset UK - 15 total since human only

n30 %>%
  filter(str_detect(Location, "United")) %>%
  group_by(year) %>%
  count() %>%
  ungroup() %>%
  mutate(ppn = n/sum(n)) %>%
  mutate(select = round(ppn*15, digits = 0))

# subset Denmark - 30 total since cattle only
n30 %>%
  filter(str_detect(Location, "Denmark")) %>%
  group_by(year) %>%
  count() %>%
  ungroup() %>%
  mutate(ppn = n/sum(n)) %>%
  mutate(select = round(ppn*30, digits = 0))

# subset Germany - 30 total since cattle only
n30 %>%
  filter(str_detect(Location, "Germany")) %>%
  group_by(year) %>%
  count() %>%
  ungroup() %>%
  mutate(ppn = n/sum(n)) %>%
  mutate(select = round(ppn*30, digits = 0))

# subset Canada cattle - 30 total
n30 %>%
  filter(str_detect(Location, "Canada")) %>%
  group_by(year) %>%
  count() %>%
  ungroup() %>%
  mutate(ppn = n/sum(n)) 

# UK select 
# since all are same sample type 
uk <- n30 %>%
  filter(str_detect(Location, "United")) %>%
  left_join(n30 %>%
              filter(str_detect(Location, "United")) %>%
              group_by(year) %>%
              count() %>%
              ungroup() %>%
              mutate(ppn = n/sum(n)) %>%
              mutate(select = round(ppn*15, digits = 0)), by = "year") %>%
  group_by(year) %>%
  group_modify(~ slice_sample(.x, n = .x$select[1])) %>%
  ungroup()

# Denmark select 

ggplot(n30 %>%
         filter(str_detect(Location, "Denmark")), aes(x=year, fill = Isolation.source))+
  geom_bar()+
  theme_classic() # same deal as uk so apply same function 

dnmk <- n30 %>%
  filter(str_detect(Location, "Denmark")) %>%
  left_join(n30 %>%
              filter(str_detect(Location, "Denmark")) %>%
              group_by(year) %>%
              count() %>%
              ungroup() %>%
              mutate(ppn = n/sum(n)) %>%
              mutate(select = round(ppn*30, digits = 0)), by = "year") %>%
  group_by(year) %>%
  group_modify(~ slice_sample(.x, n = .x$select[1])) %>%
  ungroup()

# Germany select

ggplot(n30 %>%
         filter(str_detect(Location, "Germany")), aes(x=year, fill = Isolation.source))+
  geom_bar()+
  theme_classic() # same thing (bovine or cattle but no specific sample type)

germ <- n30 %>%
  filter(str_detect(Location, "Germ")) %>%
  left_join(n30 %>%
              filter(str_detect(Location, "Germ")) %>%
              group_by(year) %>%
              count() %>%
              ungroup() %>%
              mutate(ppn = n/sum(n)) %>%
              mutate(select = round(ppn*30, digits = 0)), by = "year") %>%
  group_by(year) %>%
  group_modify(~ slice_sample(.x, n = .x$select[1])) %>%
  ungroup()

# Canada select 
ggplot(n30 %>%
         filter(str_detect(Location, "Canada")), aes(x=year, fill = Location))+
  geom_bar()+
  theme_classic()

# account for location distn and year
can <- n30 %>%
  filter(str_detect(Location, "Canada")) %>%
  left_join(n30 %>%
              filter(str_detect(Location, "Canada")) %>%
              group_by(year, Location) %>%
              count() %>%
              ungroup() %>%
              mutate(ppn = n/sum(n)) %>%
              mutate(select = round(ppn*30, digits = 0)), by = c("year", "Location")) %>%
  group_by(year, Location) %>%
  group_modify(~ slice_sample(.x, n = .x$select[1])) %>%
  ungroup()

# combine 

subset <- rbind(can %>%
                  select(colnames(n30)),
                germ %>%
                  select(colnames(n30)),
                dnmk %>%
                  select(colnames(n30)),
                uk %>% 
                  select(colnames(n30)),
                query %>%
                  filter(!Location %in% n30$Location) %>%
                  mutate(year = str_split_fixed(Collection.date, "-", 3)[,1]) %>%
                  rbind(query %>%
                          filter(Host == "Homo sapiens" & str_detect(Location, "Canada")) %>%
                          mutate(year = str_split_fixed(Collection.date, "-", 3)[,1])))

subset %>% group_by(Location) %>% count()


# now account for USA strains 

ussub1 <- usa %>%
  filter(source == "bovclin") %>%
  filter(date %in% 2018:2024) %>%
  left_join(usa %>%
              filter(source == "bovclin") %>%
              filter(date %in% 2018:2024) %>%
              group_by(date,HHS_region) %>%
              count() %>%
              ungroup() %>%
              mutate(ppn = n/sum(n)) %>%
              mutate(select = round(ppn*30, digits = 0)), by = c("date", "HHS_region")) %>%
  group_by(date, HHS_region) %>%
  group_modify(~ slice_sample(.x, n = .x$select[1])) %>%
  ungroup()

ussub2 <- usa %>%
  filter(source == "humall") %>%
  filter(date %in% 2018:2024) %>%
  left_join(usa %>%
              filter(source == "humall") %>%
              filter(date %in% 2018:2024) %>%
              group_by(date,HHS_region) %>%
              count() %>%
              ungroup() %>%
              mutate(ppn = n/sum(n)) %>%
              mutate(select = round(ppn*15, digits = 0)), by = c("date", "HHS_region")) %>%
  group_by(date, HHS_region) %>%
  group_modify(~ slice_sample(.x, n = .x$select[1])) %>%
  ungroup()

ussub<- rbind(ussub1, ussub2)

nrow(ussub)+nrow(subset)

# ---- Extract query list ----
# Brazil SRA had to be added manually based on BioSample - these are included in the final acclist
# USA SRA are not included in the acclist as the saved assemblies from a previous study were used

# saved as acclist in query folder


# ---- Combine Pools for Final Set Metadata ----
# clean up metadata and colnames to combine
colnames(ussub)
colnames(subset)

unique(subset$Host)
unique(subset$Isolation.source)
unique(ussub$agency_submitter)

all <- subset %>%
  mutate(sra_accession = Run,
         host_assoc = case_when(
           str_detect(Host, "Bos") | str_detect(Host, "bovine") | str_detect(Host, "cattle")~ "bovine",
           str_detect(Host, "Homo") ~ "human",
           
         )) %>%
  # add the specifics under region
  mutate(region = str_split_fixed(Location, ":", 2)[,2]) %>%
  mutate(region = case_when(
    str_detect(region, "United") ~ "",
    str_detect(region, "Victoria") ~ "Victoria",
    TRUE ~ region
  )) %>%
  mutate(region = case_when(
    region == "" ~ "Not Specified",
    TRUE ~ region
  )) %>%
  # add country
  mutate(country = str_split_fixed(Location, ":", 2)[,1]) %>%
  # standardize sample type
  mutate(sample_type_std = str_to_sentence(Isolation.source)) %>%
  mutate(sample_type_std = case_when(
    sample_type_std %in% c("Bovine", "Cattle", "Cattle or beef", "Necropsy", "Unk", "Human") ~ "Not Specified",
    sample_type_std == "" ~ "Not Specified",
    sample_type_std %in% c("Stool", "Feces") ~ "Feces",
    str_detect(sample_type_std, "Intest") ~ "Intestine",
    TRUE ~ sample_type_std
  )) %>%
  # year uploaded
  mutate(year_uploaded = str_split_fixed(Create.date, "-", 3)[,1]) %>%
  # biosample
  mutate(biosample=BioSample) %>%
  #submitter
  mutate(agency_submitter = Collected.by,
         year_collection = year) %>%
  select(sra_accession, biosample, year_uploaded, year_collection, host_assoc, sample_type_std, region, country) %>%
  rbind(ussub %>%
          mutate(region = HHS_region,
                 year_collection = date,
                 country = "USA") %>%
          select(sra_accession, biosample, year_uploaded, year_collection, host_assoc, sample_type_std, region, country))

#correct NDSU SRAs that were selected since names were not changed at this step of the previous analysis
all <- all %>%
  mutate(sra_accession = case_when(
    sra_accession == "NDSU10" ~ "SRR31203041",
    sra_accession == "NDSU15" ~ "SRR31203080",
    sra_accession == "NDSU21" ~ "SRR31203074",
    TRUE ~ sra_accession
  ))



# plot distributions
ggarrange(ggplot(all, aes(x = year_collection, fill = country)) +
            geom_bar(color = "white") +
            theme_classic() +
            scale_fill_viridis_d(option = "D") +
            facet_wrap(~host_assoc),
          
          ggplot(all, aes(x = host_assoc, fill = sample_type_std)) +
            geom_bar(color = "white") +
            scale_fill_viridis_d(option = "A") +
            theme_classic(), nrow = 2)

