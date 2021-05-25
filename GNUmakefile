LN_S := ln -s
RM_F := rm -rf
MKDIR_P := mkdir -p

# We use use various bash-isms in the rules.
SHELL := bash

export CC := clang
export CXX := clang++

Clang_Format := clang-format
Clang_Tidy := clang-tidy
Clang_Apply_Replacements := clang-apply-replacements-12

Buildifier := buildifier
Buildozer := buildozer

OS := $(shell uname -s)
Linux_Distribution := $(shell . /etc/os-release 2>/dev/null && echo $$NAME)

Envoy_Repository := $(HOME)/upstream/envoy

Install_Pkg_Fedora := dnf install -y

Packages_Fedora := \
	aspell \
	aspell-en \
	autoconf \
	automake \
	clang \
	cmake \
	curl \
	libcxxabi-devel \
	libcxxabi-static \
	libcxx-static \
	libtool \
	lld \
	make \
	ninja-build \
	patch \
	python3-pip \
	unzip

Install_Pkg_Ubuntu := apt install -y

Packages_Ubuntu :=  \
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
	python3-pip \
	unzip

Packages_Darwin :=  \
	aspell \
	autoconf \
	automake \
	bazelisk \
	buildifier \
	clang-format \
	cmake \
	coreutils \
	libtool \
	ninja \
	wget

# On Linux we want to use `--config-clang` to force the build to use Clang,
# but that breaks macOS because it adds `-fuse-ld=lld` which isn't supported
# on macOS.
Bazel_Build_Darwin :=
Bazel_Build_Linux := --config=clang

export CC := clang
export CXX := clang++

.PHONY: envoy
envoy: ## Build envoy
	bazel build $(Bazel_Build_$(OS)) @envoy//source/exe:envoy-static
	[[ -L envoy-static ]] || ln -s bazel-bin/external/envoy/source/exe/envoy-static

.PHONY: check
check: ## Run envoy unit tests
	bazel test $(Bazel_Build_$(OS)) @envoy//test/...

.PHONY: fetch
fetch: ## Fetch envoy build dependencies
	bazel fetch @envoy//source/exe:envoy-static
	bazel fetch @envoy//test/...

# NOTE: buildifier and buildozer are disabled since it's hard to
# match the version that Envoy CI uses.
.PHONY: format
format: ## Run envoy source format tooling
	cd $(Envoy_Repository) && \
	CLANG_FORMAT=$${CLANG_FORMAT:-$(Clang_Format)} \
		BUILDIFIER_BIN=$${BUILDIFIER_BIN:-$(Buildifier)} \
		BUILDOZER_BIN=$${BUILDOZER_BIN:-$(Buildozer)} \
		$(Envoy_Repository)/tools/code_format/check_format.py fix

.PHONY: tidy
tidy: ## Run envoy clang-tidy tooling
	cd $(Envoy_Repository) && \
	RUN_FULL_CLANG_TIDY=1 \
	APPLY_CLANG_TIDY_FIXES=1 \
	COMP_DB_TARGETS=//source/exe:envoy-static \
	CLANG_TIDY=$${CLANG_TIDY:-$(Clang_Tidy)} \
	CLANG_APPLY_REPLACEMENTS=$${CLANG_APPLY_REPLACEMENTS:-$(Clang_Apply_Replacements)} \
		$(Envoy_Repository)/ci/run_clang_tidy.sh

.PHONY: symbols
symbols: ## Build compilation database
	@cd $(Envoy_Repository) && ./tools/gen_compilation_database.py \
		--vscode --include_headers --include_genfiles --include_external

Generated_Setup_Files := .bazelrc .bazelversion bazel/get_workspace_status WORKSPACE

.PHONY: setup
setup: ## Do initial workspace setup
setup: $(Generated_Setup_Files)

.bazelrc:
	@echo "import $(Envoy_Repository)/.bazelrc" > $@

.bazelversion:
	$(LN_S) $(Envoy_Repository)/.bazelversion

bazel/get_workspace_status: bazel/get_workspace_status.in
	@sed '-es^$$Envoy_Repository^$(Envoy_Repository)^g' < $< > $@
	@chmod 755 $@

WORKSPACE: WORKSPACE.in
	@sed '-es^$$Envoy_Repository^$(Envoy_Repository)^g' < $< > $@

.PHONY: container
container: ## Package the envoy-static binary into a container image
	source /etc/os-release && [[ "$$NAME" == Fedora ]] # enforce that we have a Fedora build
	test -L envoy-static # ensure we have a envoy build
	$(RM_F) envoy
	cp $$(realpath envoy-static) envoy
	sudo docker build -t jpeach/envoy-devel:$$(date +%s) .
	$(RM_F) envoy

.PHONY: distclean
distclean: ## Deep clean of all final and intermediate artifacts
	@-bazel clean
	$(RM_F) $(Generated_Setup_Files)
	$(RM_F) envoy-static
	$(RM_F) envoy
	$(RM_F) bazel-bin bazel-envoy bazel-out bazel-testlogs

.PHONY: install-deps
install-deps: install-deps-$(OS) ## Install build dependencies

.PHONY: install-deps-Linux
install-deps-Linux:
	sudo $(Install_Pkg_$(Linux_Distribution)) $(Packages_$(Linux_Distribution))
	if ! `command -v python >/dev/null 2>&1`; then \
		sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1000; \
	fi

.PHONY: install-deps-Darwin
install-deps-Darwin:
	brew install $(Packages_$(OS))

.PHONY: help
help: ## Show this help
	@echo Targets:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9._-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
