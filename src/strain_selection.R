

# 5/4/2021.

library(magrittr)

source("src/NCBI_name_fix.R")
source("src/save_cp_pep_sh.R")

# Load metadata.
ncbi_amygdali <- read.delim("ncbi_amygdali.txt", header = T)
# Load available assemblies.
available_assemblies <- read.delim("ncbi_dataset/available_assemblies.txt", header = F)

# Remove references to any missing assemblies.
ncbi_amygdali <- ncbi_amygdali[which(ncbi_amygdali$assembly_accession %in% available_assemblies$V1),]

# Sanitize strain names.
ncbi_amygdali$final_name <- sapply(c(1:nrow(ncbi_amygdali)), 
                                  name_fix, strainlist= ncbi_amygdali)

### Write strainlists.

# Start by constructing genomedb using assemblies with: "Complete Genome".
strainlist_core <- ncbi_amygdali[which(ncbi_amygdali$assembly_level=="Complete Genome"),]

# Save strainlist_core.
write.table(strainlist_core$final_name, "genomedb/strainlist.txt",
          row.names = F, col.names = F, quote = F)

# Create strainlist_prop, and remove duplicated strains.
strainlist_prop <- ncbi_amygdali[which(ncbi_amygdali$assembly_level=="Scaffold"),]
strainlist_prop <- strainlist_prop[-which(strainlist_prop$final_name %in% strainlist_core$final_name),]

# Save strainlist_prop.
write.table(strainlist_prop$final_name, "genomedb/prop_strainlist.txt",
          row.names = F, col.names = F, quote = F)

# Write shell script to copy all relevant files into genomedb/pep.
save_faa_cp_command(rbind(strainlist_core, strainlist_prop), "src/cp_faa.sh")
