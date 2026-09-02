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
