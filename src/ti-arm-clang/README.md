
# TI Arm Clang (ti-arm-clang)

Installs the TI Arm Clang compiler toolchain for Sitara MCU development.

## Example Usage

```json
"features": {
    "ghcr.io/noahfriendo/sitara-devcontainer-features/ti-arm-clang:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | TI Arm Clang version. Override installerUrl/sha256 (and arm64InstallerUrl/arm64Sha256 on arm64) when changing this value. | string | 4.0.4.LTS |
| installerUrl | HTTPS URL of the Linux x64 TI Arm Clang installer. | string | https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-ayxs93eZNN/4.0.4.LTS/ti_cgt_armllvm_4.0.4.LTS_linux-x64_installer.bin |
| sha256 | SHA-256 checksum of the Linux x64 installer. | string | 98c60ecc259a07a54be6fcc0f55990332f493bfe5dad460c0ba83963f5dcb06f |
| arm64InstallerUrl | HTTPS URL of the Linux arm64 TI Arm Clang installer. | string | https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-ayxs93eZNN/4.0.4.LTS/ti_cgt_armllvm_4.0.4.LTS_linux-arm64_installer.bin |
| arm64Sha256 | SHA-256 checksum of the Linux arm64 installer. Required when building on linux/arm64. | string | - |

Installs the selected compiler under `/opt/ti/ti-cgt-armllvm_<version>` and
maintains `/opt/ti/ti-cgt-armllvm` as a stable link. `CG_TOOL_ROOT` and `PATH`
use the stable link.

## Architecture support

`linux/amd64` is supported out of the box. `linux/arm64` is also supported via
TI's native Linux arm64 installer; provide the `arm64Sha256` option with the
SHA-256 checksum of the arm64 installer file. Download
`ti_cgt_armllvm_4.0.4.LTS_linux-arm64_installer.bin` from TI's download page
and compute it with:

```sh
sha256sum ti_cgt_armllvm_4.0.4.LTS_linux-arm64_installer.bin
```

## Version overrides

When selecting another compiler version, provide its matching `installerUrl`,
`sha256`, `arm64InstallerUrl`, and `arm64Sha256` together. Compiler
compatibility is determined by the MCU+ SDK release being used.

## Licensing

This Feature's source is licensed under the repository's MIT license. The TI
installer and installed compiler are downloaded from TI and remain subject to
TI's separate license terms and notices. Review those terms before use.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/NoahFriendo/sitara-devcontainer-features/blob/master/src/ti-arm-clang/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
