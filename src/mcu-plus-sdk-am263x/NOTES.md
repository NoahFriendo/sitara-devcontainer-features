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
