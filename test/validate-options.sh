#!/bin/bash
set -euo pipefail

hash=0000000000000000000000000000000000000000000000000000000000000000

expect_failure() {
    local label=$1
    shift
    if "$@" >/tmp/feature-negative.log 2>&1; then
        echo "Expected failure: $label" >&2
        cat /tmp/feature-negative.log >&2
        exit 1
    fi
    echo "Passed negative validation: $label"
}

expect_checksum_mismatch() {
    local -a root=()
    local mockbin
    if [ "$(id -u)" -ne 0 ]; then
        root=(sudo)
    fi
    mockbin=$(mktemp -d)
    printf '#!/bin/sh\nexit 0\n' >"$mockbin/apt-get"
    cat >"$mockbin/curl" <<'EOF'
#!/bin/sh
while [ "$#" -gt 0 ]; do
    if [ "$1" = "--output" ]; then
        printf 'not the expected installer' >"$2"
        exit 0
    fi
    shift
done
exit 1
EOF
    chmod +x "$mockbin/apt-get" "$mockbin/curl"
    if "${root[@]}" env PATH="$mockbin:$PATH" VERSION=4.0.4.LTS INSTALLERURL=https://example.com/ SHA256="$hash" \
        sh src/ti-arm-clang/install.sh >/tmp/feature-checksum.log 2>&1; then
        echo "Expected checksum mismatch" >&2
        rm -rf "$mockbin"
        exit 1
    fi
    grep -F "FAILED" /tmp/feature-checksum.log >/dev/null || {
        echo "Failure did not come from checksum verification" >&2
        cat /tmp/feature-checksum.log >&2
        rm -rf "$mockbin"
        exit 1
    }
    rm -rf "$mockbin"
    echo "Passed negative validation: checksum mismatch"
}

for feature in ti-arm-clang sysconfig mcu-plus-sdk-am263x; do
    expect_failure "$feature malformed version" env VERSION='bad version!' INSTALLERURL=https://example.invalid/tool SHA256="$hash" sh "src/$feature/install.sh"
    expect_failure "$feature non-HTTPS URL" env VERSION=1.0 INSTALLERURL=http://example.invalid/tool SHA256="$hash" sh "src/$feature/install.sh"
    expect_failure "$feature malformed checksum" env VERSION=1.0 INSTALLERURL=https://example.invalid/tool SHA256=xyz sh "src/$feature/install.sh"
done

mockbin=$(mktemp -d)
trap 'rm -rf "$mockbin" /tmp/feature-negative.log /tmp/feature-checksum.log' EXIT
printf '#!/bin/sh\necho aarch64\n' >"$mockbin/uname"
chmod +x "$mockbin/uname"
# arm64 without arm64Sha256 must fail
expect_failure "ti-arm-clang arm64 missing arm64Sha256" env PATH="$mockbin:$PATH" VERSION=4.0.4.LTS INSTALLERURL=https://example.invalid/tool SHA256="$hash" sh src/ti-arm-clang/install.sh
# arm64 with invalid arm64Sha256 length must fail
expect_failure "ti-arm-clang arm64 malformed arm64Sha256" env PATH="$mockbin:$PATH" VERSION=4.0.4.LTS ARM64SHA256=xyz sh src/ti-arm-clang/install.sh
# arm64 with non-HTTPS arm64InstallerUrl must fail
expect_failure "ti-arm-clang arm64 non-HTTPS arm64InstallerUrl" env PATH="$mockbin:$PATH" VERSION=4.0.4.LTS ARM64INSTALLERURL=http://example.invalid/arm64 ARM64SHA256="$hash" sh src/ti-arm-clang/install.sh

printf '#!/bin/sh\necho riscv64\n' >"$mockbin/uname"
# unsupported architecture must fail
expect_failure "ti-arm-clang unsupported architecture" env PATH="$mockbin:$PATH" VERSION=4.0.4.LTS INSTALLERURL=https://example.invalid/tool SHA256="$hash" sh src/ti-arm-clang/install.sh
# mcu-plus-sdk-am263x and sysconfig also reject non-amd64
for feature in mcu-plus-sdk-am263x sysconfig; do
    expect_failure "$feature unsupported architecture" env PATH="$mockbin:$PATH" VERSION=1.0 INSTALLERURL=https://example.invalid/tool SHA256="$hash" sh "src/$feature/install.sh"
done

expect_checksum_mismatch
