# Notes on setup of this extension

The extension made using the following manuals:
[Android](https://developers.is.com/ironsource-mobile/android/android-sdk/)

## Android SDK update

Open `extension-ironsource/manifests/android/build.gradle` and change versions for the main package and adapters.

Check [Change Log](https://developers.is.com/ironsource-mobile/android/sdk-change-log/) to make sure there are no breaking changes and all new APIs implemented. Make sure you use compatable adapters using [this page](https://developers.is.com/ironsource-mobile/android/mediation-networks-android/).

## iOS SDK update

...

## Adapter adding

1. Add adapter into `game.project` for needed platform: `*adapterName*_*platformName*`.
2. Make the field you added private using `ext.properties`.
3. Add needed libraries into `gradle` of `pod` file using Mustache templates.
4. Make sure in the official adapter's documentation that no other steps needed.
