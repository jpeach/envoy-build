FROM ghcr.io/nelhage/llama as llama

FROM ubuntu:21.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y install \
        autoconf \
        automake \
        ca-certificates \
        clang \
        clangd \
        clang-format \
        clang-tidy \
        cmake \
        curl \
        curl \
        libtool \
        lld \
        llvm \
        lsb-release \
        make \
        ninja-build \
        patch \
        python \
        python3-pip \
        software-properties-common \
        unzip \
    && apt-get -y remove gcc \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && :

COPY --from=llama /llama_runtime /llama_runtime
WORKDIR /
ENTRYPOINT ["/llama_runtime"]
