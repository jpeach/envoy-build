LN_S := ln -s
RM_F := rm -rf
MKDIR_P := mkdir -p

Envoy_Repository := $(HOME)/upstream/envoy

export CC := clang
export CXX := clang++

.PHONY: envoy
envoy:
	bazel build @envoy//source/exe:envoy-static

.PHONY: check
check:
	bazel test @envoy//test/...

.PHONY: setup
setup: .bazelrc bazel/get_workspace_status WORKSPACE

.bazelrc:
	$(LN_S) $(Envoy_Repository)/.bazelrc

bazel/get_workspace_status: bazel/get_workspace_status.in
	@sed '-es^$$Envoy_Repository^$(Envoy_Repository)^g' < $< > $@
	@chmod 755 $@

WORKSPACE: WORKSPACE.in
	@sed '-es^$$Envoy_Repository^$(Envoy_Repository)^g' < $< > $@

.PHONY: distclean
distclean:
	$(RM_F) .bazelrc
	$(RM_F) WORKSPACE
	$(RM_F) bazel/get_workspace_status
	$(RM_F) bazel-bin bazel-envoy bazel-out bazel-testlogs
