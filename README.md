# IronSource Extension for Defold

Defold [native extension](https://www.defold.com/manuals/extensions/) which provides access to IronSource functionality on Android and iOS.

## Installation
To use this library in your Defold project, add the needed version URL to your `game.project` dependencies from [Releases](https://github.com/defold/extension-ironsource/releases)

<img width="401" alt="image" src="https://user-images.githubusercontent.com/2209596/202223571-c77f0304-5202-4314-869d-7a90bbeec5ec.png">

## Example

See the [example folder](https://github.com/defold/extension-ironsource/tree/main/example) to understand how to use the extension. Especially [ui.gui_script](https://github.com/defold/extension-ironsource/blob/main/example/main.gui_script) and [callback.lua](https://github.com/defold/extension-ironsource/blob/main/example/callback.lua) files.

## Setup

1. Copy/paste `[iron_source]` section from [game.project](https://github.com/defold/extension-ironsource/blob/main/game.project) file into your `game.project`.

2. If you don't need an adapter, just set `0` into an adapter's field (these fields are boolean and may be `1` or `0`.).

3. The `admob_android_appid` field should contain `app_id` if you want to use AdMob adapter specify admob_android as 1. The same for `admob_ios` and `admob_ios_appid`.

4. Use the official Android and iOS manuals for SDK integration, including everything related to the SDK functions: initialization, AD loading and showing, meta data, consent, work with user id and the other functions. Also for Adapters integration. Ignore everything related to Gradle, library installation, changes in manifests, and so on.

5. In Defold the SDK has `ironsource` namespace and all the methods are the same as in official documentation but in camel case. For example if in official documentation you see `IronSource.setMetaData("AppLovin_AgeRestrictedUser","true");` in Defold it will be: `ironsource.set_meta_data("AppLovin_AgeRestrictedUser","true")`.

6. The SDK has just one universal callback for everything. Please check [callback.lua](https://github.com/defold/extension-ironsource/blob/main/example/callback.lua) for better understanding.

---

If you have any issues, questions or suggestions please [create an issue](https://github.com/defold/extension-ironsource/issues).
