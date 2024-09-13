#TO BUILD: docker build -t tlsassistant-testbed .
#TO RUN: docker run -t tlsassistant-testbed

FROM ubuntu:18.04

# LABEL maintainer="Emiliano Rizzonelli <920a9sk42f76c765@proton.me> and Daniel Franchini <danielfranchini@virgilio.com>"

RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libgd-dev \
    libxml2 \
    libxml2-dev \
    uuid-dev \
    git \
    docker.io \
    aha \
    html2text \
    libxml2-utils \
    pandoc \
    dos2unix \
    python-pip \
    libexpat1-dev \
    geany \
    && pip install --pre tlslite-ng \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tlsassistant-testbed

COPY . /tlsassistant-testbed

RUN chmod +x /tlsassistant-testbed/run.sh

CMD ["bash", "/tlsassistant-testbed/run.sh"]
