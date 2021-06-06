FROM ghcr.io/nelhage/llama as llama

FROM envoyproxy/envoy-build-ubuntu

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
        apt-get -y install ca-certificates && \
	apt-get -y upgrade && \
        apt-get -y clean && \
	update-alternatives --install /usr/bin/cc cc /opt/llvm/bin/clang 100 && \
	update-alternatives --install /usr/bin/c++ c++ /opt/llvm/bin/clang++ 100 && \
	update-alternatives --install /usr/bin/ld ld /opt/llvm/bin/lld 100 && \
	:

COPY --from=llama /llama_runtime /llama_runtime

WORKDIR /

ENTRYPOINT ["/llama_runtime"]

