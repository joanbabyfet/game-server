FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    gcc \
    g++ \
    make \
    wget \
    unzip \
    curl \
    libreadline-dev \
    autoconf \
    automake \
    libtool \
    libtool-bin \
    pkg-config

WORKDIR /app

CMD ["bash"]