Build_Image_Repository := envoyproxy/envoy-build-ubuntu
Build_Image_Tag := 55d9e4719d2bd0accce8f829b44dab70cd42112a

# Make surw we use absolute paths here, see
# https://github.com/nelhage/llama/issues/38.
export LLAMACC_LOCAL_CC := $(shell which $(CC))
export LLAMACC_LOCAL_CXX := $(shell which $(CXX))
export LLAMACC_LOCAL_PREPROCESS := 1

# Path to generate llamacc wrapper. See
# https://github.com/bazelbuild/rules_foreign_cc/issues/665.
Llamacc_Path := /tmp/bazel/llamacc

.PHONY: install/llama
llama/install: ## Install llama
llama/install: $(Llamacc_Path)
	LLAMADIR=$$(mktemp -d) && \
	cd $${LLAMADIR} && \
		git clone --quiet --depth 1 https://github.com/nelhage/llama.git && \
		cd llama  && \
			go install ./...
	$(LN_S) llamacc $${GOBIN:-$${GOPATH:-$$HOME/go}/bin}/llamac++

.PHONY: llama/server
llama/server: ## Start the llama server
	llama daemon -start

.PHONY: llama/watch
llama/watch: ## Wath the llama server stats
	watch -n1 llama daemon -stats

.PHONY: llama/image
llama/image: ## Generate and push the llama build function image
	docker pull $(Build_Image_Repository):$(Build_Image_Tag)
	docker tag $(Build_Image_Repository):$(Build_Image_Tag) $(Build_Image_Repository):latest
	llama update-function -create --build=images/$(notdir $(Build_Image_Repository)) gcc
	@echo -n "testing that the new image can be invoked...  "
	@llama invoke gcc echo ok

$(Llamacc_Path): bazel/llamacc.in
	@mkdir -p $(dir $@)
	@LLAMACC=$(shell which llamacc) envsubst < $^ > $@
	@chmod +x $@

distclean::
	$(RM_F) $(Llamacc_Path)

# TODO(jpeach): rather than use the upstream Envoy image, use a base image of
# the current OS and run "make install-deps" in it. That would ensure that the
# remote and local build systems are the same.

