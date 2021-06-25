#!/usr/bin/env Rscript
#Script to Merge idxstats viral DNA or RNA counts from multiple samples into a single spreadsheet
#Veronica Russell
#06/21/21
#Dave Lab

#load packages, for column_to_rownames func
require(tibble)

#get command line arguments
#input order must be 
#1) tabbed file with sample ID's and their idxstat file directories
#2) a viral fasta header to virus mapping .txt key 
#3) defined output .csv file
args = commandArgs(trailingOnly=TRUE)

#get table of files
file_tbl <- read.table(args[1], header=TRUE)
head(file_tbl)
#read in reference key with shortened references
idxstats_key <- read.csv(args[2])
#define output file
output_file <- args[3]

#set up output table
final_table <- data.frame(matrix(ncol=length(file_tbl$samples) + 3,nrow=length(idxstats_key$rename), dimnames=list(NULL, c("abbrev_ref", "full_ref", "viral_type", file_tbl$samples))), check.names = FALSE)
final_table$abbrev_ref <- idxstats_key$rename
final_table$full_ref <- idxstats_key$fasta_header
final_table <- column_to_rownames(final_table, var = "full_ref")
final_table$viral_type <- idxstats_key$viral_type
head(final_table)

#loop through files and enter in table
for(i in 1:dim(file_tbl)[1]){
  #load first idxstats count file
  tmp_file <- read.table(file_tbl[i,2], header=FALSE)
  #format idxstats file
  colnames(tmp_file) <- c("full_ref", "sequence_len", "mapped_cts", "unmapped_cts")
  tmp_file <- tmp_file[1:dim(tmp_file)[1]-1,]
  
  #loop through and add counts for each reference to final table
  #ensure same number of references in key as in output table
  print(dim(tmp_file)[1])
  print(dim(final_table)[1])
  if(dim(tmp_file)[1] == dim(final_table)[1]){
    #loop through each reference
    for(j in 1:dim(tmp_file)[1]){
      #add counts to final_table at appropriate position
      final_table[tmp_file[j,1],c(file_tbl[i,]$samples)] <- tmp_file[j,3]
    }
  }
  else{
    print("There are more or less references listed than there should be for idxstat result")
  }
}

#reformat matrix for output
final_table$full_ref <- rownames(final_table)
final_table <- final_table[,c("full_ref","abbrev_ref", "viral_type", file_tbl$samples)]

#write to output
write.table(final_table, output_file, row.names = FALSE)

