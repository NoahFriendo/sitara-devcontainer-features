
# TI SysConfig (sysconfig)

Installs the headless TI SysConfig CLI for Sitara MCU development.

## Example Usage

```json
"features": {
    "ghcr.io/noahfriendo/sitara-devcontainer-features/sysconfig:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | SysConfig short version. Override installerUrl and sha256 when changing this value. | string | 1.27.0 |
| installerUrl | HTTPS URL of the Linux x64 SysConfig installer. | string | https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-nsUM6f7Vvb/1.27.0.4565/sysconfig-1.27.0_4565-setup.run |
| sha256 | SHA-256 checksum of the installer. | string | aaaeed931c5dea9fa4fa135612d773af5724e2916148bb6947ef4adc1b980517 |

Installs SysConfig under `/opt/ti/sysconfig_<version>` and maintains
`/opt/ti/sysconfig` as a stable link. `SYSCONFIG_ROOT` uses the stable link and
`sysconfig_cli` is available in `/usr/local/bin`.

The feature installs headless runtime libraries only. When selecting another
version, provide its matching Linux x64 installer URL and SHA-256 checksum.

## Architecture support

TI only publishes a `linux-x64` SysConfig installer (Electron/Node.js
application). The feature therefore requires a `linux/amd64` container. On arm64
hosts (e.g. Apple Silicon or AWS Graviton), pin the build platform in the
Dockerfile used by the dev container so the Feature also installs under x86_64
emulation:

```Dockerfile
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu-22.04
```

Then select that Dockerfile with `"build": { "dockerfile": "Dockerfile" }` in
`devcontainer.json`. Setting `runArgs` is not sufficient because Features are
installed while building the image, before run arguments are applied. Docker
Desktop for Mac enables emulation automatically; Linux hosts may need to run
`docker run --privileged --rm tonistiigi/binfmt --install amd64` once.

## Licensing

This Feature's source is licensed under the repository's MIT license. The TI
installer and installed SysConfig software are downloaded from TI and remain
subject to TI's separate license terms and notices. Review those terms before
use.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/NoahFriendo/sitara-devcontainer-features/blob/master/src/sysconfig/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
