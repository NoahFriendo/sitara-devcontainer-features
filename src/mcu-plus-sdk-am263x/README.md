
# TI MCU+ SDK for AM263x (mcu-plus-sdk-am263x)

Installs the TI MCU+ SDK and headless host tools for AM263x development.

## Example Usage

```json
"features": {
    "ghcr.io/noahfriendo/sitara-devcontainer-features/mcu-plus-sdk-am263x:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | MCU+ SDK version. Override installerUrl and sha256 when changing this value. | string | 26.00.00.06 |
| installerUrl | HTTPS URL of the AM263x MCU+ SDK Linux x64 installer. | string | https://dr-download.ti.com/software-development/software-development-kit-sdk/MD-r5FY9rRaGv/26.00.00.06.STS/mcu_plus_sdk_am263x_26_00_00_06-linux-x64-installer.run |
| sha256 | SHA-256 checksum of the installer. | string | 1dbf6f3d0df12ff5ba68e0b3e13170093fa16167139c9b77ec082f0bd4303edc |

Installs the selected SDK under `/opt/ti/mcu_plus_sdk_am263x_<version_key>`,
where `<version_key>` is the selected version with every `.` replaced by `_`
(for example, `26.00.00.06` becomes `26_00_00_06`), and maintains
`/opt/ti/mcu_plus_sdk_am263x` as a stable link. The feature exports
`MCU_PLUS_SDK_PATH` and `TOOLS_PATH=/opt/ti`.

Host packages cover SDK makefiles, signing, UART flashing, and multicore ELF
generation. The compiler and SysConfig remain separate features. When selecting
another SDK version, provide its matching Linux x64 installer URL and SHA-256,
then select the compiler and SysConfig versions documented by TI for that SDK.

## Architecture support

TI only publishes a `linux-x64` MCU+ SDK installer. The feature therefore
requires a `linux/amd64` container. On arm64 hosts (e.g. Apple Silicon or AWS
Graviton), pin the build platform in the Dockerfile used by the dev container so
the Feature also installs under x86_64 emulation:

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
installer and installed SDK are downloaded from TI and remain subject to TI's
separate license terms and notices. Review those terms before use.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/NoahFriendo/sitara-devcontainer-features/blob/master/src/mcu-plus-sdk-am263x/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
