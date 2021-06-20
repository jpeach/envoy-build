#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source /etc/os-release

readonly HERE=$(cd $(dirname $0) && pwd)

cat > Dockerfile <<EOF
FROM ghcr.io/nelhage/llama as llama

FROM ${ID}:${VERSION_ID}
ENV DEBIAN_FRONTEND noninteractive

RUN \
apt-get update && \
apt-get -y install \
	ca-certificates \
	lsb-release \
	curl \
	software-properties-common \
	autoconf \
	automake \
	clang \
	clangd \
	clang-format \
	clang-tidy \
	cmake \
	curl \
	libtool \
	lld \
	llvm \
	make \
	ninja-build \
	patch \
	python \
	python3-pip \
	unzip && \
apt-get -y remove \
	gcc &&\
apt-get -y autoremove && \
apt-get -y clean && \
:

COPY --from=llama /llama_runtime /llama_runtime
WORKDIR /
ENTRYPOINT ["/llama_runtime"]
EOF
