#!usr/bin/sh
#Veronica Russell
#03/08/20

#unmapped reads to masked viral genome for viruses included in davelab panel (EBV, HIV, KSHV, HPV, HCV, HBV, HTLV, MPV)
#takes input bam of all rna reads after human alignment using STAR and marking of PCR duplicates (aka bam filed directly from gsutil analysis bucket)
#STAR run on masked viral ref genome



IN_BAM=$1 #name sorted pcr marked duplicates file from gs://analysis_results/${ANLYSIS_ID}/picard_markduplicates__rna/picard_markduplicates__rna_Picard_MarkDuplicates.mrkdup.bam
REF_IDX=$2 #intended use: Viral masked reference from VirDetect workflow
#indexing from VirDetect workflow follows:
#STAR --runThreadN 1 --runMode genomeGenerate --genomeSAindexNbases 7 --genomeDir ${REF_IDX_DIR} --genomeFastaFiles ${REF_IDX_FASTA}
NTHREADS=$3 #nr_cpus
INCLUDE_FLAG=$4
EXCLUDE_FLAG=$5
OUT_PREF_PAIR=$6
MISMATCHNMAX=$7
MULTIMAPNMAX=$8
SAMREADBYTES=$9


#filter input bam and convert to fastqs
samtools fastq -f ${INCLUDE_FLAG} -F ${EXCLUDE_FLAG} ${IN_BAM} -1 human_unmapped_to_masked_viral_STAR1.fastq -2 human_unmapped_to_masked_viral_STAR2.fastq -s human_unmapped_to_masked_viral_STARs.fastq 2>&1 | tee -a ${OUT_PREF_PAIR}all_log.txt

#STAR RUN for pairs
STAR --genomeDir ${REF_IDX} --readFilesIn human_unmapped_to_masked_viral_STAR1.fastq human_unmapped_to_masked_viral_STAR2.fastq --runThreadN ${NTHREADS} --outFilterMismatchNmax ${MISMATCHNMAX} --outFilterMultimapNmax ${MULTIMAPNMAX} --limitOutSAMoneReadBytes ${SAMREADBYTES} --outFileNamePrefix ${OUT_PREF_PAIR}STAR_ 2>&1 | tee -a ${OUT_PREF_PAIR}all_log.txt

#sort and index for idxstats
samtools view -b ${OUT_PREF_PAIR}STAR_Aligned.out.sam | samtools sort - > ${OUT_PREF_PAIR}STAR_Aligned.sorted.out.bam 2>&1 | tee -a ${OUT_PREF_PAIR}all_log.txt
samtools index ${OUT_PREF_PAIR}STAR_Aligned.sorted.out.bam 2>&1 | tee -a ${OUT_PREF_PAIR}all_log.txt
samtools idxstats ${OUT_PREF_PAIR}STAR_Aligned.sorted.out.bam > ${OUT_PREF_PAIR}idxstats.txt 2>&1 | tee -a ${OUT_PREF_PAIR}all_log.txt

ls -ltr 2>&1 | tee -a ${OUT_PREF_PAIR}all_log.txt
ls -ltr /data/output/ | tee -a ${OUT_PREF_PAIR}all_log.txt
