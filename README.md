# RNA-Seq Salmon Pipeline Docker

A fully containerized RNA-Seq analysis workflow built on Ubuntu 22.04 that performs:

* FASTQ quality assessment with FastQC
* Read trimming with FastP
* Quality report aggregation with MultiQC
* Transcript quantification with Salmon
* Automated download of human transcriptome reference data
* Automated retrieval of SRA sequencing datasets

---

## Features

✔ Ubuntu 22.04 base image

✔ Human transcriptome reference (GRCh38, Ensembl Release 115)

✔ Pre-built Salmon index

✔ Automatic SRA dataset download

✔ FastQC quality control

✔ FastP read trimming

✔ MultiQC reporting

✔ Salmon transcript quantification

✔ SSH access enabled

---

## Included Bioinformatics Tools

| Tool        | Purpose                     |
| ----------- | --------------------------- |
| FastQC      | Raw read quality assessment |
| MultiQC     | QC report aggregation       |
| FastP       | Read trimming and filtering |
| Salmon      | Transcript quantification   |
| HISAT2      | Read alignment              |
| Bowtie2     | Read alignment              |
| BWA         | Sequence alignment          |
| SAMtools    | BAM/SAM processing          |
| BCFtools    | Variant processing          |
| SRA Toolkit | SRA data retrieval          |

---

## Reference Data

The container automatically downloads:

**Species:** Homo sapiens

**Genome Build:** GRCh38

**Transcriptome:** Ensembl Release 115 cDNA

Source:

https://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/cdna/

---

## Example Dataset

The image downloads and processes:

SRR38803505

using:

```bash
prefetch SRR38803505
fasterq-dump SRR38803505
```

---

## Pipeline Workflow

```text
SRA Download
     │
     ▼
FASTQ Generation
     │
     ▼
FastQC (Raw Reads)
     │
     ▼
FastP Trimming
     │
     ▼
FastQC (Trimmed Reads)
     │
     ▼
MultiQC Report
     │
     ▼
Salmon Quantification
     │
     ▼
Transcript Abundance Results
```

---

## Build Image

```bash
docker build -t kartzz/ngssalmon:latest .
```

---

## Run Container

```bash
docker run -it --rm \
-p 2222:22 \
kartzz/ngssalmon:latest
```

---

## SSH Access

SSH is enabled by default.

```text
Username: root
Password: root
```

Connect using:

```bash
ssh root@localhost -p 2222
```

---

## Directory Structure

```text
/ref
├── Homo_sapiens.GRCh38.cdna.all.fa
└── salmon_index

/data
├── *.fastq.gz
├── trimmed/
├── qc/
└── quants/

/pipeline
└── pipeline.py
```

---

## Output Files

### Quality Reports

```text
/data/qc/
```

Contains:

* FastQC HTML reports
* FastQC ZIP archives
* MultiQC report

### Trimmed Reads

```text
/data/trimmed/
```

Contains:

* Filtered FASTQ files
* Adapter-trimmed reads

### Quantification Results

```text
/data/quants/
```

Each sample contains:

```text
sample/
├── quant.sf
├── cmd_info.json
├── lib_format_counts.json
└── aux_info/
```

---

## Default Execution

When the container starts it automatically:

1. Starts the SSH service
2. Executes the RNA-Seq pipeline

```bash
service ssh start && python3 /pipeline/pipeline.py
```

---

## Docker Hub

Pull the image:

```bash
docker pull kartzz/ngssalmon:latest
```

Run:

```bash
docker run -it --rm -p 2222:22 \
<kartzz>/ngssalmon:latest
```

---

## Notes

* Large image size due to bundled reference data and Salmon index.
* Suitable for educational, testing, and small-scale RNA-Seq workflows.
* Uses Salmon automatic library type detection (`-l A`).
* Built for reproducible transcript quantification in containerized environments.
Suggested Docker Hub Metadata

Repository Name

rnaseq-salmon-pipeline

Short Description

Containerized RNA-Seq workflow with FastQC, FastP, MultiQC and Salmon using Ensembl GRCh38 human transcriptome  reference.

## License

MIT License
