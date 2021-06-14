Build_Image_Repository := jpeach/current-$(shell echo $(Linux_Distribution) | tr [:upper:] [:lower:])-build

# Make sure we use absolute paths here, see
# https://github.com/nelhage/llama/issues/38.
export LLAMACC_LOCAL_CC := $(shell which $(CC))
export LLAMACC_LOCAL_CXX := $(shell which $(CXX))

export LLAMACC_LOCAL_PREPROCESS := 1 	# Pre-process locally
export LLAMACC_FULL_PREPROCESS := 0 	# Only pre-process includes locally.
export LLAMACC_VERBOSE := 0		# Don't be verbose

# Path to generate llamacc wrapper. See
# https://github.com/bazelbuild/rules_foreign_cc/issues/665.
Llamacc_Prefix := /tmp/bazel

# Use the real compiler name for the wrapper script, because some
# builds tweak flags based on the program name.
Llamacc_Path := $(Llamacc_Prefix)/$(notdir $(CC))
Llamacxx_Path := $(Llamacc_Prefix)/$(notdir $(CXX))

NPROC := $(shell getconf _NPROCESSORS_CONF)

.PHONY: install/llama
llama/install: ## Install llama
llama/install: $(Llamacc_Path) $(Llamacxx_Path)
	LLAMADIR=$$(mktemp -d) && \
	cd $${LLAMADIR} && \
		git clone --quiet --depth 1 https://github.com/nelhage/llama.git && \
		cd llama  && \
			go install ./...
	$(LN_S) llamacc $${GOBIN:-$${GOPATH:-$$HOME/go}/bin}/llamac++

.PHONY: llama/server
llama/run/server: ## Start the llama server
	llama daemon -start -cc-concurrency 500

.PHONY: llama/watch
llama/run/watch: ## Watch the llama server stats
	watch -n1 llama daemon -stats

.PHONY: llama/image
llama/image: ## Generate and push the llama build function image
	llama update-function -create --build=images/$(notdir $(Build_Image_Repository)) gcc
	@echo -n "testing that the new image can be invoked...  "
	@llama invoke gcc echo ok

$(Llamacc_Path): bazel/llamacc.in
	@mkdir -p $(dir $@)
	@LLAMACC=$(shell which llamacc) envsubst < $^ > $@
	@chmod +x $@

$(Llamacxx_Path): bazel/llamacc.in
	@mkdir -p $(dir $@)
	@LLAMACC=$(shell which llamac++) envsubst < $^ > $@
	@chmod +x $@

distclean::
	$(RM_F) $(Llamacc_Path)

# TODO(jpeach): rather than use the upstream Envoy image, use a base image of
# the current OS and run "make install-deps" in it. That would ensure that the
# remote and local build systems are the same.

.PHONY: llama/build/envoy
llama/build/envoy: ## Build envoy
	CC=$(Llamacc_Path) CXX=$(Llamacxx_Path) \
	   bazel build $(Bazel_Build_Args) $(Bazel_Build_$(OS)) @envoy//source/exe:envoy-static
	[[ -L envoy-static ]] || ln -s bazel-bin/external/envoy/source/exe/envoy-static

