# IronSource Extension for Defold

Defold [native extension](https://www.defold.com/manuals/extensions/) which provides access to IronSource functionality on Android and iOS.

## Installation
To use this library in your Defold project, add the needed version URL to your `game.project` dependencies from [Releases](https://github.com/defold/extension-ironsource/releases)

<img width="401" alt="image" src="https://user-images.githubusercontent.com/2209596/202223571-c77f0304-5202-4314-869d-7a90bbeec5ec.png">

## Example

See the [example folder](https://github.com/defold/extension-ironsource/tree/main/example) to understand how to use the extension. Especially [ui.gui_script](https://github.com/defold/extension-ironsource/blob/main/example/main.gui_script) and [callback.lua](https://github.com/defold/extension-ironsource/blob/main/example/callback.lua) files.

## Setup

1. Copy/paste `[iron_source]` section from [game.project](https://github.com/defold/extension-ironsource/blob/main/game.project) file into your `game.project`.

2. If you don't need an adapter, just remove text for the field (use restore button) but keep this empty field in the `game.project` file.
For example, If you don't need `Pangle` on Android, click `Restore` button for it:

<img width="610" alt="image" src="https://user-images.githubusercontent.com/2209596/235677588-5b387f86-f9b7-4a91-9d92-2a40195a70a3.png">

The fields may contain any text for including into the bundle and stay empty for excluding.

3. The `admob_android` field should contain `app_id` if you wanna use it or stay empty if not.

4. Use the official Android and iOS manuals for the SDK integration in everething related to the SDK functions: initialization, AD loading and showing, meta data, consent, work with user id and the other functions. Also for Adapters integration. Ignore everething related to Gradle and library installation, changes in manifests and so on.

5. In Defold the SDK has `ironsource` namespace and all the methods are the same as in official documentation but in camel case. For ecample if in official documentation you see `IronSource.setMetaData("AppLovin_AgeRestrictedUser","true");` in Defold it will be: `ironsource.set_meta_data("AppLovin_AgeRestrictedUser","true")`

6. The SDK has just one universal callback for everething. Please check [callback.lua](https://github.com/defold/extension-ironsource/blob/main/example/callback.lua) for better understanding.

---

If you have any issues, questions or suggestions please [create an issue](https://github.com/defold/extension-ironsource/issues).
