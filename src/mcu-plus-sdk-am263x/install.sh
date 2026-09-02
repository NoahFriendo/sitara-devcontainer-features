#!/bin/sh
set -eu

fail() { echo "ERROR: mcu-plus-sdk-am263x: $*" >&2; exit 1; }

SDK_VERSION=${VERSION:-26.00.00.06}
INSTALLERURL=${INSTALLERURL:-https://dr-download.ti.com/software-development/software-development-kit-sdk/MD-r5FY9rRaGv/26.00.00.06.STS/mcu_plus_sdk_am263x_26_00_00_06-linux-x64-installer.run}
SHA256=${SHA256:-1dbf6f3d0df12ff5ba68e0b3e13170093fa16167139c9b77ec082f0bd4303edc}
PYELFTOOLS_URL=https://files.pythonhosted.org/packages/f8/64/711030d9fe9ccaf6ee3ab1bcf4801c6bb3d0e585af18824a50b016b4f39c/pyelftools-0.31-py3-none-any.whl
PYELFTOOLS_SHA256=f52de7b3c7e8c64c8abc04a79a1cf37ac5fb0b8a49809827130b858944840607

[ "$(uname -m)" = "x86_64" ] || fail "only linux/amd64 is supported; on arm64 hosts use '--platform linux/amd64' or 'runArgs: [\"--platform=linux/amd64\"]' in devcontainer.json"
case "$SDK_VERSION" in ''|*[!0-9.]*) fail "invalid version '$SDK_VERSION'" ;; esac
case "$INSTALLERURL" in https://*) ;; *) fail "installerUrl must use HTTPS" ;; esac
[ "${#SHA256}" -eq 64 ] || fail "sha256 must contain 64 hexadecimal characters"
case "$SHA256" in *[!0-9A-Fa-f]*) fail "sha256 must contain only hexadecimal characters" ;; esac
[ -r /etc/os-release ] || fail "cannot identify the Linux distribution"
. /etc/os-release
case "${ID:-} ${ID_LIKE:-}" in *debian*|*ubuntu*) ;; *) fail "only Debian and Ubuntu base images are supported" ;; esac

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl file git make openssh-client openssl \
    python3 python3-bcrypt python3-cffi python3-construct python3-cryptography \
    python3-nacl python3-paramiko python3-pycparser python3-serial python3-six \
    python3-tqdm python3-venv python3-xmodem unzip xz-utils zip
rm -rf /var/lib/apt/lists/*

# Ubuntu 22.04's pyelftools is too old for SDK 26 multicore ELF generation.
wheel=$(mktemp /tmp/pyelftools.XXXXXX.whl)
trap 'rm -f "$wheel"' EXIT HUP INT TERM
curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error --retry 3 "$PYELFTOOLS_URL" --output "$wheel"
printf '%s  %s\n' "$PYELFTOOLS_SHA256" "$wheel" | sha256sum -c -
purelib=$(python3 -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')
mkdir -p "$purelib"
unzip -qo "$wheel" -d "$purelib"
rm -f "$wheel"
trap - EXIT HUP INT TERM

install_root=/opt/ti
version_key=$(printf '%s' "$SDK_VERSION" | tr . _)
version_root="$install_root/mcu_plus_sdk_am263x_$version_key"
stable_root="$install_root/mcu_plus_sdk_am263x"
mkdir -p "$install_root"
if [ ! -d "$version_root/source" ]; then
    installer=$(mktemp /tmp/mcu-plus-sdk-am263x.XXXXXX.run)
    trap 'rm -f "$installer"' EXIT HUP INT TERM
    curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error --retry 3 "$INSTALLERURL" --output "$installer"
    printf '%s  %s\n' "$SHA256" "$installer" | sha256sum -c -
    chmod 0755 "$installer"
    "$installer" --mode unattended --prefix "$install_root"
    rm -f "$installer"
    trap - EXIT HUP INT TERM
fi
[ -d "$version_root/source" ] || fail "installer did not create $version_root"
ln -sfn "$version_root" "$stable_root"
chmod -R a+rX "$version_root"
python3 -c 'import elftools; assert elftools.__version__ == "0.31"'
echo "Installed MCU+ SDK for AM263x $SDK_VERSION"
