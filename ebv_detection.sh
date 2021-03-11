#!usr/bin/sh
#Veronica Russell
#05/04/20

#unmapped reads to masked ebv genome last used
#takes input bam of all rna reads after human alignment using STAR and marking of PCR duplicates (aka bam filed directly from gsuti analysis bucket)
#STAR run on only masked ebv ref genome



IN_BAM=$1 #pcr marked duplicates file from gs://analysis_results/${ANLYSIS_ID}/picard_markduplicates__rna/picard_markduplicates__rna_Picard_MarkDuplicates.mrkdup.bam
REF_IDX=$2 #intended use: EBV masked reference (virus_masked_hg38_NC007605.1.fa) from VirDetect workflow
#indexing from VirDetect workflow follows:
#STAR --runThreadN 1 --runMode genomeGenerate --genomeSAindexNbases 7 --genomeDir ${REF_IDX_DIR} --genomeFastaFiles ${REF_IDX_FASTA}
NTHREADS=$3 #nr_cpus
INCLUDE_FLAG=$4
EXCLUDE_FLAG=$5
OUT_PREF_PAIR=$6
OUT_PREF_SINGLE=$7
MISMATCHNMAX=$8
MULTIMAPNMAX=$9
SAMREADBYTES=$10


#filter input bam and convert to fastqs

samtools fastq -f ${INCLUDE_FLAG} -F ${EXCLUDE_FLAG} ${IN_BAM} -1 human_unmapped_to_masked_ebv_STAR1.fastq -2 human_unmapped_to_masked_ebv_STAR2.fastq -s human_unmapped_to_masked_ebv_STARs.fastq

#currently must account for singletons separately
#STAR RUN for pairs
STAR --genomeDir ${REF_IDX} --readFilesIn human_unmapped_to_masked_ebv_STAR1.fastq human_unmapped_to_masked_ebv_STAR2.fastq --runThreadN ${NTHREADS} --outFilterMismatchNmax ${MISMATCHNMAX} --outFilterMultimapNmax ${MULTIMAPNMAX} --limitOutSAMoneReadBytes ${SAMREADBYTES} --outFileNamePrefix ${OUT_PREF_PAIR}

#STAR RUN for singletons
STAR --genomeDir ${REF_IDX} --readFilesIn human_unmapped_to_masked_ebv_STARs.fastq --runThreadN ${NTHREADS} --outFilterMismatchNmax ${MISMATCHNMAX} --outFilterMultimapNmax ${MULTIMAPNMAX} --limitOutSAMoneReadBytes ${SAMREADBYTES} --outFileNamePrefix ${OUT_PREF_SINGLE}

ls -ltr
ls -ltr /data/ebv_detection/output/