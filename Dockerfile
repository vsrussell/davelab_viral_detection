# work from latest LTS ubuntu release
FROM ubuntu:18.04

# run update and install necessary tools
RUN apt-get update -y && apt-get install -y \
    build-essential \
    libnss-sss \
    curl \
    vim \
    less \
    wget \
    unzip \
    cmake \
    python \
    gawk \
    python-pip \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libnss-sss \
    libbz2-dev \
    liblzma-dev \
    bzip2 \
    libcurl4-openssl-dev \
    libssl-dev \
    git \
    autoconf \
    rna-star \
    samtools \
    bsdmainutils

# install numpy and pysam
WORKDIR /usr/local/bin
RUN pip install numpy
RUN pip install cython
RUN pip install pysam

# get lumpy script
ADD https://api.github.com/repos/vsrussell/davelab_viral_detection/git/refs/heads/ version.json
RUN git clone https://github.com/vsrussell/davelab_viral_detection.git
RUN cp davelab_viral_detection/viral_detection_rna.sh .
RUN cp davelab_viral_detection/ebv_detection.sh .
RUN cp -r davelab_viral_detection/masked_viral_genomes_idx_STAR .
RUN cp -r davelab_viral_detection/masked_ebv_genome_idx_STAR .
