#!usr/bin/sh
#Veronica Russell
#04/20/21

#viral detecton for viruses of interest (EBV, HIV, KSHV, HPV, HCV, HBV, HTLV, MPV) from sample dna sequencing 

IN_BAM=$1 #name sorted pcr marked duplicates file from gs://analysis_results/${ANALYSIS_ID}/filter_chrom_reads__short_insert__dna/filter_chrom_reads__short_insert__dna_FilterChromReads_FilterLongInsertExonicReads.${DAVELAB_ID}.small_insert.bam
REF_IDX=$2 #intended use: Viral masked reference from VirDetect workflow index with bwa index
NTHREADS=$3 #nr_cpus
INCLUDE_FLAG=$4
EXCLUDE_FLAG=$5
OUT_PREF=$6 #ouput naming

#filter input bam and convert to fastqs
samtools fastq -f ${INCLUDE_FLAG} -F ${EXCLUDE_FLAG} ${IN_BAM} -1 human_unmapped_dna_to_masked_viral_BWA1.fastq -2 human_unmapped_dna_to_masked_viral_BWA2.fastq -s human_unmapped_dna_to_masked_viral_BWAs.fastq 2>&1 | tee -a ${OUT_PREF}_all_log.txt

#run bwa
bwa mem -t ${NTHREADS} -M ${REF_IDX} human_unmapped_dna_to_masked_viral_BWA1.fastq human_unmapped_dna_to_masked_viral_BWA2.fastq -o ${OUT_PREF}_paired_aligned.sam 2>&1 | tee -a ${OUT_PREF}_all_log.txt
bwa mem -t ${NTHREADS} -M ${REF_IDX} human_unmapped_dna_to_masked_viral_BWAs.fastq -o ${OUT_PREF}_single_aligned.sam 2>&1 | tee -a ${OUT_PREF}_all_log.txt

#convert to bam before sorting
samtools view -b ${OUT_PREF}_paired_aligned.sam > ${OUT_PREF}_paired_aligned.bam 2>&1 | tee -a ${OUT_PREF}_all_log.txt
samtools view -b ${OUT_PREF}_single_aligned.sam > ${OUT_PREF}_single_aligned.bam 2>&1 | tee -a ${OUT_PREF}_all_log.txt

#concatenate bam files
samtools cat ${OUT_PREF}_paired_aligned.bam ${OUT_PREF}_single_aligned.bam -o ${OUT_PREF}_aligned.bam 2>&1 | tee -a ${OUT_PREF}_all_log.txt

#sort and index merged paired and singleton alignments
samtools sort ${OUT_PREF}_aligned.bam > ${OUT_PREF}_aligned_sorted.bam 2>&1 | tee -a ${OUT_PREF}_all_log.txt
samtools index ${OUT_PREF}_aligned_sorted.bam 2>&1 | tee -a ${OUT_PREF}_all_log.txt
wait

#idxstats for quantification
samtools idxstats ${OUT_PREF}_aligned_sorted.bam > ${OUT_PREF}_idxstats.txt 2>&1 | tee -a ${OUT_PREF}_all_log.txt

ls -ltr 2>&1 | tee -a ${OUT_PREF}_all_log.txt
ls -ltr /data/output/ | tee -a ${OUT_PREF}_all_log.txt
