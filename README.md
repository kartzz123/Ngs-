RNA-Seq Quantification Pipeline (Salmon + QC Toolkit)

This Docker image provides a fully automated RNA-Seq analysis pipeline built on Ubuntu 22.04. It includes tools for quality control, trimming, and transcript quantification using Salmon, along with a pre-configured reference transcriptome and example dataset.

Features
 End-to-end RNA-Seq pipeline
Pre-installed bioinformatics tools:
QC: FastQC, MultiQC
Trimming: fastp
Alignment tools: HISAT2, Bowtie2, BWA
Processing: samtools, bcftools
Quantification: Salmon
 Preloaded human transcriptome (Ensembl GRCh38)
 Prebuilt Salmon index
Example dataset from SRA (SRR37945512)
 Automated pipeline execution 
SSH access enabled inside container
Included Workflow

The pipeline performs the following steps automatically:

Download RNA-Seq data
Fetches paired-end reads using SRA Toolkit
Quality Control (Raw Reads)
Runs FastQC on raw FASTQ files
Read Trimming
Uses fastp to clean reads
Quality Control (Trimmed Reads)
Runs FastQC again
Aggregates reports using MultiQC
Transcript Quantification
Uses Salmon for fast transcript-level quantification
