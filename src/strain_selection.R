
library(magrittr)

source("src/NCBI_name_fix.R")
source("src/save_cp_pep_sh.R")

# Load metadata.
ncbi_amygdali <- read.delim("ncbi_amygdali.txt", header = T)
# Load available assemblies.
available_assemblies <- read.delim("ncbi_dataset/available_assemblies.txt", header = F)

# Remove references to any missing assemblies.
ncbi_amygdali <- ncbi_amygdali[which(ncbi_amygdali$assembly_accession %in% available_assemblies$V1), ]

# Sanitize strain names.
ncbi_amygdali$final_name <- sapply(c(1:nrow(ncbi_amygdali)), 
                                   name_fix, strainlist = ncbi_amygdali)

### Write strainlist.

# Start with assemblies: "Complete Genome".
strainlist <- ncbi_amygdali[which(ncbi_amygdali$assembly_level=="Complete Genome"),]

# Create list of remaining genomes, and remove duplicated strains.
strainlist_add <- ncbi_amygdali[which(ncbi_amygdali$assembly_level=="Scaffold"),]
strainlist_add <- strainlist_add[-which(strainlist_add$final_name %in% strainlist$final_name),]

strainlist <- rbind(strainlist, strainlist_add)

# Save strainlist.
write.table(strainlist$final_name, "genomedb/strainlist.txt",
            row.names = F, col.names = F, quote = F)

# Write shell script to copy all relevant files into genomedb/pep.
save_faa_cp_command(strainlist, "src/cp_faa.sh")
