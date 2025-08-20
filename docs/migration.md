<!-- order: 20 -->

# Migration

## Table of Contents

- [Manual Migration from Visual Studio Code to BAX](#manual-migration)
- [Semi-Automatic Migration with "Sync Settings" Extension](#semi-automatic-migration)

## <a id="manual-migration"></a>Manual Migration from Visual Studio Code to BAX

BAX (and a freshly cloned copy of vscode built from source) stores its extension files in `~/.vscode-oss`. So if you currently have Visual Studio Code installed, your extensions won't automatically populate. You can copy the `extensions` from `~/.vscode/extensions` to `~/.vscode-oss/extensions`.

Visual Studio Code stores its `keybindings.json` and `settings.json` file in these locations:

- __Windows__: `%APPDATA%\Code\User`
- __macOS__: `$HOME/Library/Application Support/Code/User`
- __Linux__: `$HOME/.config/Code/User`

You can copy these files to the BAX user settings folder:

- __Windows__: `%APPDATA%\BAX\User`
- __macOS__: `$HOME/Library/Application Support/BAX/User`
- __Linux__: `$HOME/.config/BAX/User`

To copy your settings manually:

- In Visual Studio Code, go to Settings (`Meta+,`)
- Click the three dots `...` and choose 'Open settings.json'
- Copy the contents of settings.json into the same place in BAX

## <a id="semi-automatic-migration"></a>Semi-Automatic Migration with "Sync Settings" Extension

The [**Sync Settings**](https://github.com/zokugun/vscode-sync-settings) extension can simplify the migration process by enabling synchronization of settings, keybindings, extensions, and more between Visual Studio Code and BAX. Its author is the main maintainer of BAX ;)

The extension is available in the Visual Studio Marketplace, OpenVSX or directly in its GitHub repository.

### Steps:

1. Install the **Sync Settings** extension in both Visual Studio Code and BAX.
2. Configure the extension on both Visual Studio Code and BAX:
  - Open Command Palette (`Meta+Shift+P`).
  - Search for `Sync Settings: Open the repository settings` and execute the command.
  - Configure the repository
3. Export your current settings from Visual Studio Code:
  - Open Command Palette (`Meta+Shift+P`).
  - Search for `Sync Settings: Upload (user -> repository)` and execute the command.
4. Import the settings into BAX:
  - I recommend the setting `"syncSettings.openOutputOnActivity": true,`.
  - Open Command Palette (`Meta+Shift+P`).
  - Search for `Sync Settings: Download (repository -> user)` and execute the command.
  - Wait for all the extensions to be downloaded and installed (follow logs in the `Output` panel) before restarting BAX.

This method ensures that all supported configurations are seamlessly transferred.
