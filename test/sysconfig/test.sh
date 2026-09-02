#!/bin/bash
set -e
source dev-container-features-test-lib
check "stable SysConfig path" test -x /opt/ti/sysconfig/sysconfig_cli.sh
check "SysConfig command" command -v sysconfig_cli
check "SysConfig version" bash -c "sysconfig_cli --version | grep -F '1.27.0+4565'"
check "SysConfig environment" test "$SYSCONFIG_ROOT" = /opt/ti/sysconfig
reportResults
