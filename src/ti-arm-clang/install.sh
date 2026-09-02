#!/bin/sh
set -eu

fail() { echo "ERROR: ti-arm-clang: $*" >&2; exit 1; }

TOOLCHAIN_VERSION=${VERSION:-4.0.4.LTS}
INSTALLERURL=${INSTALLERURL:-https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-ayxs93eZNN/4.0.4.LTS/ti_cgt_armllvm_4.0.4.LTS_linux-x64_installer.bin}
SHA256=${SHA256:-98c60ecc259a07a54be6fcc0f55990332f493bfe5dad460c0ba83963f5dcb06f}
ARM64INSTALLERURL=${ARM64INSTALLERURL:-https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-ayxs93eZNN/4.0.4.LTS/ti_cgt_armllvm_4.0.4.LTS_linux-arm64_installer.bin}
ARM64SHA256=${ARM64SHA256:-}

arch=$(uname -m)
case "$arch" in
    x86_64)
        url="$INSTALLERURL"
        checksum="$SHA256"
        [ "${#checksum}" -eq 64 ] || fail "sha256 must contain 64 hexadecimal characters"
        case "$checksum" in *[!0-9A-Fa-f]*) fail "sha256 must contain only hexadecimal characters" ;; esac
        ;;
    aarch64)
        url="$ARM64INSTALLERURL"
        checksum="$ARM64SHA256"
        [ -n "$checksum" ] || fail "arm64Sha256 is required for linux/arm64; download $ARM64INSTALLERURL and compute it with: sha256sum <installer>"
        [ "${#checksum}" -eq 64 ] || fail "arm64Sha256 must contain 64 hexadecimal characters"
        case "$checksum" in *[!0-9A-Fa-f]*) fail "arm64Sha256 must contain only hexadecimal characters" ;; esac
        ;;
    *)
        fail "unsupported architecture '$arch'; only linux/amd64 and linux/arm64 are supported"
        ;;
esac
case "$TOOLCHAIN_VERSION" in ''|*[!0-9A-Za-z._-]*) fail "invalid version '$TOOLCHAIN_VERSION'" ;; esac
case "$url" in https://*) ;; *) fail "installer URL must use HTTPS" ;; esac
[ -r /etc/os-release ] || fail "cannot identify the Linux distribution"
. /etc/os-release
case "${ID:-} ${ID_LIKE:-}" in *debian*|*ubuntu*) ;; *) fail "only Debian and Ubuntu base images are supported" ;; esac

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
rm -rf /var/lib/apt/lists/*

install_root=/opt/ti
version_root="$install_root/ti-cgt-armllvm_$TOOLCHAIN_VERSION"
stable_root="$install_root/ti-cgt-armllvm"
mkdir -p "$install_root"
if [ ! -x "$version_root/bin/tiarmclang" ]; then
    installer=$(mktemp /tmp/ti-arm-clang.XXXXXX.bin)
    trap 'rm -f "$installer"' EXIT HUP INT TERM
    curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error --retry 3 "$url" --output "$installer"
    printf '%s  %s\n' "$checksum" "$installer" | sha256sum -c -
    chmod 0755 "$installer"
    "$installer" --mode unattended --prefix "$install_root"
    rm -f "$installer"
    trap - EXIT HUP INT TERM
fi
[ -x "$version_root/bin/tiarmclang" ] || fail "installer did not create $version_root"
ln -sfn "$version_root" "$stable_root"
chmod -R a+rX "$version_root"
"$stable_root/bin/tiarmclang" --version | head -n 1
