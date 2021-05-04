
# 4/15/2021.

# Create shell script to copy pep.fa files into genomedb/
# From: ncbi_dataset/data/ 
# To: genomedb/pep/

# Print a single command.
print_faa_cp_command <- function(row, strainlist){
  return(paste("cp ncbi_dataset/data/", 
               strainlist[row, "assembly_accession"],
               "/*protein.faa ",
               "genomedb/pep/",
               strainlist[row, "final_name"],
               ".pep.fa",
               sep = ""))
}

# Save all commands for a given strainlist.
save_faa_cp_command <- function(strainlist, file_name){
  commands <- c(sapply(c(1:nrow(strainlist)), print_faa_cp_command,
                       strainlist = strainlist))
  commands <- c("#! bash \n", commands)
  write.table(commands, file = file_name, 
              row.names = F, quote = F, col.names = F)
}


