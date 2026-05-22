FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------
# 1. Install dependencies + Salmon
# -------------------------------
RUN apt-get update && apt-get install -y \
    fastqc \
    multiqc \
    hisat2 \
    bowtie2 \
    bwa \
    samtools \
    bcftools \
    fastp \
    sra-toolkit \
    wget \
    curl \
    unzip \
    gzip \
    python3 \
    python3-pip \
    openssh-server \
    sudo \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    build-essential \
    ca-certificates \
    salmon \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# 2. Configure SSH
# -------------------------------
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

# -------------------------------
# 3. Download transcriptome
# -------------------------------
WORKDIR /ref

RUN wget https://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz && \
    gunzip Homo_sapiens.GRCh38.cdna.all.fa.gz

# -------------------------------
# 4. Build Salmon index
# -------------------------------
RUN salmon index \
    -t Homo_sapiens.GRCh38.cdna.all.fa \
    -i salmon_index

# -------------------------------
# 5. Download SRA data
# -------------------------------
WORKDIR /data

RUN prefetch SRR37945512 && \
    fasterq-dump SRR37945512 --split-files && \
    gzip *.fastq

# -------------------------------
# 6. Pipeline script
# -------------------------------
WORKDIR /pipeline

RUN cat > /pipeline/pipeline.py << 'EOF'
#!/usr/bin/env python3

import os
import glob
import subprocess

DATA_DIR = "/data"
TRIM_DIR = os.path.join(DATA_DIR, "trimmed")
QC_DIR = os.path.join(DATA_DIR, "qc")
QUANT_DIR = os.path.join(DATA_DIR, "quants")

os.makedirs(TRIM_DIR, exist_ok=True)
os.makedirs(QC_DIR, exist_ok=True)
os.makedirs(QUANT_DIR, exist_ok=True)

r1_files = sorted(glob.glob(os.path.join(DATA_DIR, "*_1.fastq.gz")))

if not r1_files:
    print("ERROR: No paired-end FASTQ files found")
    exit(1)

all_raw = []

for r1 in r1_files:
    r2 = r1.replace("_1.fastq.gz", "_2.fastq.gz")
    all_raw.extend([r1, r2])

print("Running FastQC on raw reads...")

subprocess.run(["fastqc", *all_raw, "-o", QC_DIR], check=True)

trimmed_pairs = []

for r1 in r1_files:
    r2 = r1.replace("_1.fastq.gz", "_2.fastq.gz")
    sample = os.path.basename(r1).replace("_1.fastq.gz", "")

    out1 = os.path.join(TRIM_DIR, sample + "_1.trim.fastq.gz")
    out2 = os.path.join(TRIM_DIR, sample + "_2.trim.fastq.gz")

    subprocess.run([
        "fastp",
        "-i", r1,
        "-I", r2,
        "-o", out1,
        "-O", out2
    ], check=True)

    trimmed_pairs.append((out1, out2))

all_trimmed = [f for pair in trimmed_pairs for f in pair]

print("Running FastQC on trimmed reads...")

subprocess.run(["fastqc", *all_trimmed, "-o", QC_DIR], check=True)

print("Running MultiQC...")

subprocess.run(["multiqc", QC_DIR, "-o", QC_DIR], check=True)

print("Running Salmon quantification...")

for r1, r2 in trimmed_pairs:
    sample = os.path.basename(r1).split("_1.trim")[0]
    outdir = os.path.join(QUANT_DIR, sample)

    subprocess.run([
        "salmon",
        "quant",
        "-i", "/ref/salmon_index",
        "-l", "A",
        "-1", r1,
        "-2", r2,
        "-p", "4",
        "-o", outdir
    ], check=True)

print("Pipeline completed successfully!")
EOF

RUN chmod +x /pipeline/pipeline.py

# -------------------------------
# 7. Default command
# -------------------------------
CMD ["sh", "-c", "service ssh start && python3 /pipeline/pipeline.py"]
