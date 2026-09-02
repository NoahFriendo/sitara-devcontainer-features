#!/bin/sh
set -eu

fail() { echo "ERROR: sysconfig: $*" >&2; exit 1; }

SYSCONFIG_VERSION=${VERSION:-1.27.0}
INSTALLERURL=${INSTALLERURL:-https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-nsUM6f7Vvb/1.27.0.4565/sysconfig-1.27.0_4565-setup.run}
SHA256=${SHA256:-aaaeed931c5dea9fa4fa135612d773af5724e2916148bb6947ef4adc1b980517}

[ "$(uname -m)" = "x86_64" ] || fail "only linux/amd64 is supported; on arm64 hosts use '--platform linux/amd64' or 'runArgs: [\"--platform=linux/amd64\"]' in devcontainer.json"
case "$SYSCONFIG_VERSION" in ''|*[!0-9.]*) fail "invalid version '$SYSCONFIG_VERSION'" ;; esac
case "$INSTALLERURL" in https://*) ;; *) fail "installerUrl must use HTTPS" ;; esac
[ "${#SHA256}" -eq 64 ] || fail "sha256 must contain 64 hexadecimal characters"
case "$SHA256" in *[!0-9A-Fa-f]*) fail "sha256 must contain only hexadecimal characters" ;; esac
[ -r /etc/os-release ] || fail "cannot identify the Linux distribution"
. /etc/os-release
case "${ID:-} ${ID_LIKE:-}" in *debian*|*ubuntu*) ;; *) fail "only Debian and Ubuntu base images are supported" ;; esac

export DEBIAN_FRONTEND=noninteractive
apt-get update

select_package() {
    for package do
        if apt-cache show "$package" 2>/dev/null | grep -q "^Package: $package$"; then
            printf '%s\n' "$package"
            return
        fi
    done
    fail "none of these packages are available: $*"
}

asound_package=$(select_package libasound2 libasound2t64)
atk_bridge_package=$(select_package libatk-bridge2.0-0 libatk-bridge2.0-0t64)
gtk_package=$(select_package libgtk-3-0 libgtk-3-0t64)
apt-get install -y --no-install-recommends \
    ca-certificates curl "$asound_package" "$atk_bridge_package" \
    "$gtk_package" libnss3 libxss1
rm -rf /var/lib/apt/lists/*

install_root=/opt/ti
version_root="$install_root/sysconfig_$SYSCONFIG_VERSION"
stable_root="$install_root/sysconfig"
mkdir -p "$install_root"
if [ ! -x "$version_root/sysconfig_cli.sh" ]; then
    installer=$(mktemp /tmp/sysconfig.XXXXXX.run)
    trap 'rm -f "$installer"' EXIT HUP INT TERM
    curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error --retry 3 "$INSTALLERURL" --output "$installer"
    printf '%s  %s\n' "$SHA256" "$installer" | sha256sum -c -
    chmod 0755 "$installer"
    "$installer" --mode unattended --prefix "$version_root"
    rm -f "$installer"
    trap - EXIT HUP INT TERM
fi
[ -x "$version_root/sysconfig_cli.sh" ] || fail "installer did not create $version_root/sysconfig_cli.sh"
ln -sfn "$version_root" "$stable_root"
printf '#!/bin/sh\nexec "%s/sysconfig_cli.sh" "$@"\n' "$stable_root" > /usr/local/bin/sysconfig_cli
chmod 0755 /usr/local/bin/sysconfig_cli
chmod -R a+rX "$version_root"
"$stable_root/sysconfig_cli.sh" --version
