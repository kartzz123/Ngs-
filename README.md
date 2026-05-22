What this Docker image does

This image (built with Docker) creates a complete RNA-seq analysis environment that:

Installs all required bioinformatics tools
Downloads human reference transcriptome
Builds a Salmon index
Downloads real sequencing data (SRA)
Runs a full automated pipeline (QC → trimming → quantification)
Enables SSH access
RNA-Seq Pipeline Docker Image

This Docker image provides a fully automated RNA-seq analysis workflow with pre-installed tools, reference data, and example sequencing dataset.

🔧 Included Tools
FastQC – quality control
MultiQC – QC summary reports
fastp – read trimming
HISAT2, Bowtie2, BWA – alignment tools
Samtools, BCFtools – data processing
SRA Toolkit – sequence data download
Salmon – transcript quantification

Features

Ubuntu 22.04 base image
Pre-downloaded human transcriptome (GRCh38)
Pre-built Salmon index
Example dataset included (SRR37945512)
Fully automated pipeline execution
Python-based workflow script
SSH access enabled
 Pipeline Workflow

The container automatically performs:

Quality Control
FastQC on raw FASTQ files
Read Trimming
fastp removes adapters and low-quality reads
Post-trim QC
FastQC + MultiQC report generation
Quantification
Salmon estimates transcript expression levels
