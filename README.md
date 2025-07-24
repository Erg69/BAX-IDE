<div id="bax-logo" align="center">
    <br />
    <img src="./icons/stable/codium_cnl.svg" alt="BAX Logo" width="200"/>
    <h1>BAX IDE</h1>
    <h3>Custom Code Editor Based on Visual Studio Code</h3>
</div>

<div id="badges" align="center">

[![current release](https://img.shields.io/github/release/Erg69/BAX-IDE.svg)](https://github.com/Erg69/BAX-IDE/releases)
[![license](https://img.shields.io/github/license/Erg69/BAX-IDE.svg)](https://github.com/Erg69/BAX-IDE/blob/master/LICENSE)

[![build status (linux)](https://img.shields.io/github/actions/workflow/status/Erg69/BAX-IDE/stable-linux.yml?branch=master&label=build%28linux%29)](https://github.com/Erg69/BAX-IDE/actions/workflows/stable-linux.yml?query=branch%3Amaster)
[![build status (macos)](https://img.shields.io/github/actions/workflow/status/Erg69/BAX-IDE/stable-macos.yml?branch=master&label=build%28macOS%29)](https://github.com/Erg69/BAX-IDE/actions/workflows/stable-macos.yml?query=branch%3Amaster)
[![build status (windows)](https://img.shields.io/github/actions/workflow/status/Erg69/BAX-IDE/stable-windows.yml?branch=master&label=build%28windows%29)](https://github.com/Erg69/BAX-IDE/actions/workflows/stable-windows.yml?query=branch%3Amaster)

</div>

**BAX IDE is a custom code editor built on top of VSCodium, which itself is built from [Microsoft's `vscode` repository](https://github.com/microsoft/vscode) with additional customizations and branding.**

## Table of Contents

- [Download/Install](#download-install)
- [Build](#build)
- [Why BAX IDE](#why)
- [More Info](#more-info)
- [Supported Platforms](#supported-platforms)

## <a id="download-install"></a>Download/Install

:tada: :tada:
Download latest release here:
[releases](https://github.com/Erg69/BAX-IDE/releases)
:tada: :tada:

## <a id="build"></a>Build

Build instructions can be found [here](https://github.com/Erg69/BAX-IDE/blob/master/docs/howto-build.md)

### Quick Build
```bash
# For BAX IDE
./dev/build-bax.sh

# For development
./dev/build.sh
```

## <a id="why"></a>Why BAX IDE

BAX IDE is a customized distribution of Visual Studio Code that includes:

- **Custom branding and theming**
- **Enhanced features and tools**
- **No telemetry tracking**
- **MIT licensed binaries**
- **Community-driven development**

This project builds upon the excellent work of the VSCodium project, which provides freely-licensed binaries of Visual Studio Code. BAX IDE adds additional customizations and features tailored for specific development workflows.

## <a id="more-info"></a>More Info

### Documentation

For more information on building, customizing, and using BAX IDE, check out the documentation in the [docs](./docs/) directory.

### Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

### How are the BAX IDE binaries built?

The build process is based on VSCodium's build system with additional customizations. Check out the workflow files in `.github/workflows` for complete build automation.

## <a id="supported-platforms"></a>Supported Platforms

The minimal version is limited by the core component Electron, you may want to check its [platform prerequisites](https://www.electronjs.org/docs/latest/development/build-instructions-gn#platform-prerequisites).

- [x] macOS (`zip`, `dmg`) macOS 10.15 or newer x64
- [x] macOS (`zip`, `dmg`) macOS 11.0 or newer arm64
- [x] GNU/Linux x64 (`deb`, `rpm`, `AppImage`, `snap`, `tar.gz`)
- [x] GNU/Linux arm64 (`deb`, `rpm`, `snap`, `tar.gz`)
- [x] GNU/Linux armhf (`deb`, `rpm`, `tar.gz`)
- [x] GNU/Linux riscv64 (`tar.gz`)
- [x] GNU/Linux loong64 (`tar.gz`)
- [x] GNU/Linux ppc64le (`tar.gz`)
- [x] Windows 10 / Server 2012 R2 or newer x64
- [x] Windows 10 / Server 2012 R2 or newer arm64

## <a id="thanks"></a>Special thanks

<table>
  <tr>
    <td><a href="https://github.com/VSCodium/vscodium" target="_blank">VSCodium Project</a></td>
    <td>for the foundation and build system</td>
  </tr>
  <tr>
    <td><a href="https://github.com/microsoft/vscode" target="_blank">Microsoft VSCode</a></td>
    <td>for the excellent base editor</td>
  </tr>
</table>

## <a id="license"></a>License

[MIT](https://github.com/Erg69/BAX-IDE/blob/master/LICENSE)
