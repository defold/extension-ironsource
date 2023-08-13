# Notes on setup of this extension

The extension made using the following manuals:
[Android](https://developers.is.com/ironsource-mobile/android/android-sdk/)
[iOS](https://developers.is.com/ironsource-mobile/ios/ios-sdk/)

When you are updating extension, please update `version` in `extension-ironsource/ext.properties`. This version is used for reporting to IronSource as the version of the extension.

## Android SDK update

Open `updater` folder in terminal and run `android.py` which will change versions of the main package and adapters in Gradle file.

Check [Change Log](https://developers.is.com/ironsource-mobile/android/sdk-change-log/) to make sure there are no breaking changes and all new APIs implemented. Make sure you use compatable adapters using [this page](https://developers.is.com/ironsource-mobile/android/mediation-networks-android/).

## iOS SDK update

Open `updater` folder in terminal and run `ios.py` which will change versions of the main package and adapters in Podsfile.

Check [Change Log](https://developers.is.com/ironsource-mobile/ios/sdk-change-log/) to make sure there are no breaking changes and all new APIs implemented. Make sure you use compatable adapters using [this page](https://developers.is.com/ironsource-mobile/ios/mediation-networks-ios/).

Update `SKAdNetworkItems` using [this page](https://developers.is.com/ironsource-mobile/ios/managing-skadnetwork-ids/). IronSource is adapted by default. Also, it is nice to reduce count of duplicates by removing all the keys which are in IronSource section from the other sections.

## Adapter adding

1. Add adapter into `game.project` for needed platform: `*adapterName*_*platformName*`.
2. Make the field you added private using `ext.properties`.
3. Add needed libraries into `gradle` of `pod` file using Mustache templates.
4. Make sure in the official adapter's documentation that no other steps needed.
