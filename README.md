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

## Recommended Bazel settings

If you are building on a desktop class machine, Bazel tends to eat all the CPU
and memory. Below are the `~/.bazelrc` settings that I use to improve my build
experience. I generate the number of build jobs to be 2 less than the number od
installed CPUs.

```
build --jobs 6
build --local_ram_resources=HOST_RAM*0.75
build --repository_cache=~/.cache/bazel/repo
build --disk_cache=~/.cache/bazel/disk
build --verbose_failures

fetch --repository_cache=~/.cache/bazel/repo

query --repository_cache=~/.cache/bazel/repo

startup --batch_cpu_scheduling
startup --io_nice_level 7

test --jobs 6
test --local_ram_resources=HOST_RAM*0.75
test --compilation_mode=dbg
test --repository_cache=~/.cache/bazel/repo
test --verbose_failures
test --test_verbose_timeout_warnings
test --test_output=errors
```

## Remote building with Llama

[llama](https://github.com/nelhage/llama) lets you farms build jobs out to AWS
Lambda, effectively letting you use unlimited build parallelism.

To quickly get this set up, there are some convenience build targets.

```bash
# Start by installing llama
$ make llama/install
# Next, build the build container image and push it to your AWS lambda stack
$ make llama/image
# You need to run the llama server separately because the Bazel sandbox
# interferes with the server autostart in ways that are awkward to work
# around.
$ make llama/server &
# Now you can build envoy with llama
$ CC=/tmp/bazel/llamacc bazel build --jobs=1000 --config=clang @envoy//source/exe:envoy-static
```

## Other notes

The `--config-libc++` build option is broken due to [bazelbuild/bazel#13071](https://github.com/bazelbuild/bazel/issues/13071).
