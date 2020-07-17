LN_S := ln -s
RM_F := rm -rf
MKDIR_P := mkdir -p

export CC := clang
export CXX := clang++

Clang_Format := clang-format

OS := $(shell uname -s)
Linux_Distribution := $(shell source /etc/os-release 2>/dev/null && echo $$NAME)

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
	unzip

Install_Pkg_Ubuntu := apt-get install -y

Packages_Ubuntu :=  \
	autoconf \
	automake \
	clang \
	cmake \
	curl \
	libtool \
	make \
	ninja-build \
	patch \
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
		BUILDIFIER_BIN=$${BUILDIFIER_BIN:-true} \
		BUILDOZER_BIN=$${BUILDOZER_BIN:-true} \
		$(Envoy_Repository)/tools/check_format.py fix

.PHONY: symbols
symbols: ## Build compilation database
	@cd $(Envoy_Repository) && ./tools/gen_compilation_database.py \
		--vscode --include_headers --include_genfiles --include_external --run_bazel_build

.PHONY: setup
setup: ## Do initial workspace setup
setup: .bazelrc bazel/get_workspace_status WORKSPACE

.bazelrc:
	@echo "import $(Envoy_Repository)/.bazelrc" > $@

bazel/get_workspace_status: bazel/get_workspace_status.in
	@sed '-es^$$Envoy_Repository^$(Envoy_Repository)^g' < $< > $@
	@chmod 755 $@

WORKSPACE: WORKSPACE.in
	@sed '-es^$$Envoy_Repository^$(Envoy_Repository)^g' < $< > $@

.PHONY: container
container: ## Package the envoy-static binary into a container image
	source /etc/os-release && [[ "$$NAME" == Fedora ]] # enforce that we hav a Fedora build
	test -L envoy-static # ensure we have a envoy build
	$(RM_F) envoy
	cp $$(realpath envoy-static) envoy
	sudo docker build -t jpeach/envoy-devel:$$(date +%s) .
	$(RM_F) envoy

.PHONY: distclean
distclean: ## Deep clean of all final and intermediate artifacts
	@-bazel clean
	$(RM_F) .bazelrc
	$(RM_F) WORKSPACE
	$(RM_F) envoy-static
	$(RM_F) envoy
	$(RM_F) bazel/get_workspace_status
	$(RM_F) bazel-bin bazel-envoy bazel-out bazel-testlogs

.PHONY: install-deps
install-deps: install-deps-$(OS)

.PHONY: install-deps-Linux
install-deps-Linux:
	sudo $(Install_Pkg_$(Linux_Distribution)) $(Packages_$(Linux_Distribution))
	go get -u github.com/bazelbuild/bazelisk

.PHONY: install-deps-Darwin
install-deps-Darwin:
	brew install $(Packages_$(OS))

.PHONY: help
help: ## Show this help
	@echo Targets:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9._-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
