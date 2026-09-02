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
