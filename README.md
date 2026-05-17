# Ngs-
Ngs-pipeline 


FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------
# 1. Install dependencies + SSH
# -------------------------------
RUN apt-get update && apt-get install -y \
    fastqc \
    multiqc \
    wget curl unzip \
    python3 python3-pip \
    r-base \
    openssh-server \
    sudo \
    libcurl4-openssl-dev libxml2-dev libssl-dev \
    build-essential \
    && apt-get clean

# -------------------------------
# 2. Configure SSH
# -------------------------------
RUN mkdir /var/run/sshd

# Set root password (change later)
RUN echo 'root:root' | chpasswd

# Allow root login (for testing)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

# -------------------------------
# 3. Install Salmon
# -------------------------------
RUN wget -q https://github.com/COMBINE-lab/salmon/releases/download/v1.10.2/salmon-1.10.2_linux_x86_64.tar.gz && \
    tar -xzf salmon-1.10.2_linux_x86_64.tar.gz && \
    mv salmon-1.10.2_linux_x86_64 /opt/salmon && \
    ln -s /opt/salmon/bin/salmon /usr/local/bin/salmon

# -------------------------------
# 4. Install R packages
# -------------------------------
RUN R -e "install.packages(c('tximport','readr'), repos='https://cloud.r-project.org/')"

# -------------------------------
# 5. Download GRCh38 + transcriptome
# -------------------------------
WORKDIR /ref

RUN wget -q ftp://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz && \
    gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

RUN wget -q ftp://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz && \
    gunzip Homo_sapiens.GRCh38.cdna.all.fa.gz

# -------------------------------
# 6. Build Salmon index
# -------------------------------
RUN salmon index \
    -t Homo_sapiens.GRCh38.cdna.all.fa \
    -i salmon_index

# -------------------------------
# 7. Create pipeline script safely
# -------------------------------
WORKDIR /pipeline

RUN printf '#!/bin/bash\n\
set -e\n\
\n\
echo "Step 1: Running FastQC"\n\
mkdir -p /data/qc\n\
fastqc /data/*.fastq.gz -o /data/qc/\n\
\n\
echo "Step 2: Running MultiQC"\n\
multiqc /data/qc/ -o /data/qc/\n\
\n\
echo "Step 3: Running Salmon quant"\n\
mkdir -p /data/quants\n\
\n\
salmon quant -i /ref/salmon_index \\\n\
  -l A \\\n\
  -1 /data/*_1.fastq.gz \\\n\
  -2 /data/*_2.fastq.gz \\\n\
  -p 4 \\\n\
  -o /data/quants/sample\n\
\n\
echo "Pipeline completed!"\n' > /pipeline/run_pipeline.sh

RUN chmod +x /pipeline/run_pipeline.sh

# -------------------------------
# 8. Working directory
# -------------------------------
WORKDIR /data

# -------------------------------
# 9. Start SSH + pipeline together
# -------------------------------
CMD service ssh start && /pipeline/run_pipeline.sh
