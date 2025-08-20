<!-- order: 10 -->

# Getting all the Telemetry Out

This page explains how BAX handles telemetry and how to ensure your privacy.

## Table of Contents

- [Telemetry in BAX](#telemetry)
- [Replacements to Microsoft Online Services](#replacements)
- [Checking for Telemetry](#checking)
- [Additional Privacy Settings](#additional-settings)
- [BAX Announcements](#announcements)
- [Malicious & Deprecated Extensions](#malicious-extensions)

## <a id="telemetry"></a>Telemetry in BAX

Even though we do not pass the telemetry build flags (and go out of our way to cripple the baked-in telemetry), Microsoft will still track usage by default.

We do however set the default `telemetry.enableTelemetry` and `telemetry.enableCrashReporter` values to `false`. You can see those by viewing your BAX `settings.json` and searching for `telemetry`.

It is also highly recommended that you review all the settings that "use online services" by following [these instructions](https://code.visualstudio.com/docs/getstarted/telemetry#_managing-online-services). The `@tag:usesOnlineServices` filter on the settings page will show that by default:

- Extensions auto check for updates and auto install updates
- Searches within the app are sent to an online service for "natural language processing"
- Updates to the app are fetched in the background

These can all be disabled.

__Please note that some extensions send telemetry data to Microsoft as well. We have no control over this and can only recommend removing the extension.__ _(For example, the C# extension `ms-vscode.csharp` sends tracking data to Microsoft.)_

## <a id="replacements"></a>Replacements to Microsoft Online Services

When searching the `@tag:usesOnlineServices` filter, note that while the "Update: Mode" setting description still says "The updates are fetched from a Microsoft online service", BAX's build script [sets the `updateUrl` field](https://github.com/BAX/bax/blob/master/prepare_vscode.sh#L135) in `product.json` directly to the GitHub page, so enabling that setting won't actually result in any calls to Microsoft online service.

Likewise, while the descriptions for "Extensions: Auto Check Updates" and "Extensions: Auto Update" include the same phrase, BAX [replaces](https://github.com/BAX/bax/blob/master/prepare_vscode.sh#L121) the Visual Studio Marketplace with Open VSX, so these settings won't call Microsoft, either.

## <a id="checking"></a>Checking for Telemetry

If you want to verify that no telemetry is being sent, you can use network monitoring tools like:

- Wireshark
- Little Snitch (macOS)
- GlassWire (Windows)

Look for connections to Microsoft domains and telemetry endpoints.

## <a id="additional-settings"></a>Additional Privacy Settings

For maximum privacy, you can add these settings to your `settings.json`:

```json
{
  "telemetry.enableTelemetry": false,
  "telemetry.enableCrashReporter": false,
  "telemetry.feedback.enabled": false,
  "update.enableWindowsBackgroundUpdates": false,
  "update.mode": "manual",
  "workbench.enableExperiments": false,
  "workbench.settings.enableNaturalLanguageSearch": false
}
```

These settings will disable various telemetry and tracking features.

## <a id="announcements"></a>BAX Announcements

The Welcome page in BAX displays announcements that are fetched from the project's GitHub repository.

If you prefer to disable this feature, you can set the `workbench.welcomePage.extraAnnouncements` setting to `false` in your `settings.json`.

## <a id="malicious-extensions"></a>Malicious & Deprecated Extensions

The definitions for malicious and deprecated extensions are dynamically loaded from the following URL:
https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json.

If you prefer to avoid any external connections, you can set the`extensions.excludeUnsafes` setting to `false` in your `settings.json`.
However, this is not recommended as it may reduce the safety of your environment.
