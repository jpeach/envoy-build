FROM ghcr.io/nelhage/llama as llama

# The official build images aren't tagged with symbolic names, only with the
# SHA that matches the Envoy version. For this FROM line to work, you need to
# pull the SHA image and tag it as :latest.
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

