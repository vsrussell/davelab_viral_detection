#!usr/bin/sh
#Veronica Russell
#04/20/21

#viral detecton for viruses of interest (EBV, HIV, KSHV, HPV, HCV, HBV, HTLV, MPV) from sample dna sequencing 

IN_BAM=$1 #pcr marked duplicates file from gs://analysis_results/${ANALYSIS_ID}/filter_chrom_reads__short_insert__dna/filter_chrom_reads__short_insert__dna_FilterChromReads_FilterLongInsertExonicReads.${DAVELAB_ID}.small_insert.bam
REF_IDX=$2 #intended use: Viral masked reference from VirDetect workflow index with bwa index
NTHREADS=$3 #nr_cpus
INCLUDE_FLAG=$4
EXCLUDE_FLAG=$5
OUT_PREF_PAIR=$6 #ouput naming

#filter input bam and convert to fastqs
samtools fastq -f ${INCLUDE_FLAG} -F ${EXCLUDE_FLAG} ${IN_BAM} -1 human_unmapped_dna_to_masked_viral_BWA1.fastq -2 human_unmapped_dna_to_masked_viral_BWA2.fastq -s /dev/null 2>&1 | tee -a ${OUT_PREF_PAIR}_log.txt

#run bwa
bwa mem -t ${NTHREADS} -M ${REF_IDX} human_unmapped_dna_to_masked_viral_BWA1.fastq human_unmapped_dna_to_masked_viral_BWA2.fastq -o ${OUT_PREF_PAIR}_aligned.sam 2>&1 | tee -a ${OUT_PREF_PAIR}_log.txt


#sort and index for idxstats
samtools view -b ${OUT_PREF_PAIR}_aligned.sam | samtools sort - > ${OUT_PREF_PAIR}_aligned_sorted.bam 2>&1 | tee -a ${OUT_PREF_PAIR}_log.txt
samtools index ${OUT_PREF_PAIR}_aligned_sorted.bam 2>&1 | tee -a ${OUT_PREF_PAIR}_log.txt
samtools idxstats ${OUT_PREF_PAIR}_aligned_sorted.bam > ${OUT_PREF_PAIR}_idxstats.txt 2>&1 | tee -a ${OUT_PREF_PAIR}_log.txt

ls -ltr 2>&1 | tee -a ${OUT_PREF_PAIR}_log.txt
ls -ltr /data/viral_detection/output/
