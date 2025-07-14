# Contributing

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

#### Table Of Contents

- [Code of Conduct](#code-of-conduct)
- [Reporting Bugs](#reporting-bugs)
- [Making Changes](#making-changes)

## Code of Conduct

This project and everyone participating in it is governed by the [BAX IDE Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Reporting Bugs

### Before Submitting an Issue

Before creating bug reports, please check existing issues and [the Troubleshooting page](https://github.com/Erg69/BAX-IDE/blob/master/docs/troubleshooting.md) as you might find out that you don't need to create one.
When you are creating a bug report, please include as many details as possible. Fill out [the required template](https://github.com/Erg69/BAX-IDE/issues/new?&labels=bug&&template=bug_report.md), the information it asks for helps us resolve issues faster.

## Making Changes

If you want to make changes, please read [the Build page](./docs/howto-build.md).

### Building BAX IDE

To build BAX IDE, you can use our custom build script:

```bash
# Build with BAX-specific settings
./dev/build-bax.sh

# Or use the standard VSCodium build process
./dev/build.sh
```

### Updating patches

If you want to update the existing patches, please follow the section [`Patch Update Process - Semi-Automated`](./docs/howto-build.md#patch-update-process-semiauto).

### Add a new patch

- first, you need to build BAX IDE
- then use the command `./dev/patch.sh <your patch name>`, to initiate a new patch
- when the script pauses at `Press any key when the conflict have been resolved...`, open `vscode` directory in **BAX IDE**
- run `npm run watch`
- run `./script/code.sh`
- make your changes
- press any key to continue the script `patch.sh`

### BAX-Specific Customizations

For BAX-specific changes, please add patches to the `patches/user/` directory. These patches are preserved during upstream merges from VSCodium.

### Upstream Compatibility

This project maintains compatibility with upstream VSCodium. When making changes:

1. Prefer environment variable overrides over direct file edits
2. Use the `patches/user/` directory for custom patches
3. Test that changes work with upstream merges
4. Document any breaking changes

## Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes (following the guidelines above)
4. Test your changes thoroughly
5. Submit a pull request

Thank you for contributing to BAX IDE!
