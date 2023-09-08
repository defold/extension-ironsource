---
title: Defold IronSource extension API documentation
brief: This manual covers how to get use IronSource ad mediation to show ads on iOS and Android in Defold.
---

# Defold IronSource extension API documentation

This extension provides a unified and simple to use interface to use IronSource ad mediation on iOS and Android.


## Installation
To use IronSource in your Defold project, add a version of the IronSource extension to your `game.project` dependencies from the list of available [Releases](https://github.com/defold/extension-ironsource/releases). Find the version you want, copy the URL to ZIP archive of the release and add it to the project dependencies.

![](add-dependency.png)

Select `Project->Fetch Libraries` once you have added the version to `game.project` to download the version and make it available in your project.

## Setup

1. Copy/paste `[iron_source]` section from [game.project](https://github.com/defold/extension-ironsource/blob/main/game.project) file into your `game.project`.

2. If you don't need an adapter, just set `0` into an adapter's field (these fields are boolean and may be `1` or `0`.).

3. The `admob_android_appid` field should contain `app_id` if you want to use AdMob adapter specify admob_android as 1. The same for `admob_ios` and `admob_ios_appid`.

4. Use the official Android and iOS manuals for SDK integration, including everything related to the SDK functions: initialization, AD loading and showing, meta data, consent, work with user id and the other functions. Also for Adapters integration. Ignore everything related to Gradle, library installation, changes in manifests, and so on.

5. In Defold the SDK has `ironsource` namespace and all the methods are the same as in official documentation but in camel case. For example if in official documentation you see `IronSource.setMetaData("AppLovin_AgeRestrictedUser","true");` in Defold it will be: `ironsource.set_meta_data("AppLovin_AgeRestrictedUser","true")`.

6. The SDK has just one universal callback for everything. Please check [callback.lua](https://github.com/defold/extension-ironsource/blob/main/example/callback.lua) for better understanding.

## Example

See the [example folder](https://github.com/defold/extension-ironsource/tree/main/example) to understand how to use the extension. Especially [ui.gui_script](https://github.com/defold/extension-ironsource/blob/main/example/main.gui_script) and [callback.lua](https://github.com/defold/extension-ironsource/blob/main/example/callback.lua) files.


## Troubleshooting

### "Error 508: Interstitial - Server response contains no interstitial data"

If you get such an error, make sure that you initialize ADS right and use test placements. If it still doesn't work ask IronSource support.

## Source code

The source code is available on [GitHub](https://github.com/defold/extension-ironsource)


## API reference
