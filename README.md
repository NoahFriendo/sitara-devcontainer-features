# Sitara AM263x Dev Container Features

Composable, headless development tools for TI Sitara AM263x MCUs. Features are
published from this repository to GitHub Container Registry.

| Feature | Default tool version |
| --- | --- |
| `mcu-plus-sdk-am263x` | MCU+ SDK 26.00.00.06 |
| `ti-arm-clang` | TI Arm Clang 4.0.4 LTS |
| `sysconfig` | SysConfig 1.27.0+4565 |

These defaults are the compatible versions documented together by TI for MCU+
SDK 26.00.00.06.

The release test matrix covers Debian 12, Ubuntu 22.04, and Ubuntu 24.04. The
composed SDK/compiler/SysConfig build is exercised on Ubuntu 22.04 and 24.04.

## Usage

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
    "features": {
        "ghcr.io/noahfriendo/sitara-devcontainer-features/mcu-plus-sdk-am263x:1": {},
        "ghcr.io/noahfriendo/sitara-devcontainer-features/ti-arm-clang:1": {},
        "ghcr.io/noahfriendo/sitara-devcontainer-features/sysconfig:1": {}
    }
}
```

The features export stable paths independent of the selected versions:

- `MCU_PLUS_SDK_PATH=/opt/ti/mcu_plus_sdk_am263x`
- `CG_TOOL_ROOT=/opt/ti/ti-cgt-armllvm`
- `SYSCONFIG_ROOT=/opt/ti/sysconfig`
- `TOOLS_PATH=/opt/ti`

`tiarmclang` and `sysconfig_cli` are available on `PATH`.

## Version overrides

Each feature has `version`, `installerUrl`, and `sha256` options. Override all
three together because TI download paths are not derivable from version numbers
and each MCU+ SDK release supports specific compiler and SysConfig versions.

```jsonc
"ghcr.io/noahfriendo/sitara-devcontainer-features/ti-arm-clang:1": {
    "version": "<version>",
    "installerUrl": "https://.../linux-x64-installer.bin",
    "sha256": "<64-character-sha256>"
}
```

The installers must be HTTPS Linux x64 packages. Checksums are mandatory and are
verified before an installer runs. There is intentionally no automatic `latest`
resolution.

`ti-arm-clang` also accepts `arm64InstallerUrl` and `arm64Sha256` for use on
`linux/arm64`. Override all four URL and checksum options together when changing
the compiler version on arm64.

## Compatibility and scope

- Supported base images: Debian and Ubuntu distributions using `apt`.
- Supported architectures:
  - `linux/amd64`: all three features work out of the box.
  - `linux/arm64`: `ti-arm-clang` installs via TI's native arm64 build (provide
    the `arm64Sha256` option). `mcu-plus-sdk-am263x` and `sysconfig` require a
    `linux/amd64` container because TI only publishes x86_64 installers for
    those tools; use Docker platform-level emulation (see each feature's notes).
- Included workflow: SDK makefiles, TI Arm compilation, SysConfig CLI generation,
  signing, UART flashing dependencies, and boot-image generation.
- Excluded: CCS, UniFlash, graphical tools, debug-probe integration, and USB rules.

The tools are installed beneath `/opt/ti`, remain readable and executable by the
container's non-root user, and do not change `remoteUser` or `containerUser`.

## Licensing

TI installers and binaries are downloaded directly from TI and are not stored in
this repository. By using these features, you are responsible for reviewing and
complying with the licenses and terms accompanying each TI tool.

## Development and tests

Run all feature and composed-toolchain tests with:

```bash
npx --yes @devcontainers/cli@0.88.0 features test .
```

The composed scenario builds TI's AM263x hello-world example through SysConfig
generation, R5F compilation/linking, and multicore ELF packaging.

See [CONTRIBUTING.md](CONTRIBUTING.md) for validation and documentation
generation commands.
