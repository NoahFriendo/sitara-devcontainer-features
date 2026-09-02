#!/bin/bash
set -e
source dev-container-features-test-lib

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cp -a "$MCU_PLUS_SDK_PATH/examples/hello_world" "$workdir/hello_world"
example="$workdir/hello_world/am263x-cc/r5fss0-0_nortos/ti-arm-clang"

check "non-root scenario" bash -c "test \"$(id -u)\" -ne 0"
check "generate, compile, link, and package hello-world" make -C "$example" all
check "application ELF" test -s "$example/hello_world.release.out"
check "multicore ELF" test -s "$example/hello_world.release.mcelf"
reportResults
