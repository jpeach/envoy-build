# envoy-build

This is a simple Bazel workspace for building Envoy.

Before building envoy for the first time `make install-deps` will attempt
to install any necessary build dependencies for your system (you still
have to BYO bazelisk).

Next, run `make setup` to link the Envoy source code. Use the
`Envoy_Repository` variable to override the default source code path.

Now you can run any of the following targets:

| Command | Purpose |
| --- | --- |
|  check         |        Run envoy unit tests
|  container     |        Package the envoy-static binary into a container image
|  distclean     |        Deep clean of all final and intermediate artifacts
|  envoy         |        Build envoy
|  fetch         |        Fetch envoy build dependencies
|  format        |        Run envoy source format tooling
|  help          |        Show this help
|  install-deps  |        Install build dependencies
|  setup         |        Do initial workspace setup
|  symbols       |        Build compilation database
