#!/bin/bash
set -e
source dev-container-features-test-lib
check "stable compiler path" test -x /opt/ti/ti-cgt-armllvm/bin/tiarmclang
check "compiler version" bash -c "tiarmclang --version | grep -F '4.0.4.LTS'"
check "compiler environment" test "$CG_TOOL_ROOT" = /opt/ti/ti-cgt-armllvm
check "non-root readable" test -r /opt/ti/ti-cgt-armllvm/include/c/stdio.h
reportResults
