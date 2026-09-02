#!/bin/bash
set -e
source dev-container-features-test-lib
check "stable SDK path" test -d /opt/ti/mcu_plus_sdk_am263x/source
check "SDK environment" test "$MCU_PLUS_SDK_PATH" = /opt/ti/mcu_plus_sdk_am263x
check "TI tools root" test "$TOOLS_PATH" = /opt/ti
check "OpenSSL" openssl version
check "SDK Python modules" python3 -c "import bcrypt, cffi, construct, cryptography, elftools, nacl, paramiko, serial, tqdm, xmodem; assert elftools.__version__ == '0.31'"
reportResults
