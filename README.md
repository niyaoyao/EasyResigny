# EasyResigny
**EasyResigny** is a Mac tool for user to resign iOS App.

## Note
1. To use **EasyResigny** to resign iOS App, you must ensure your App has been decrypted.You can use [dumpdecrypted](https://github.com/stefanesser/dumpdecrypted) to decrypt your app or download jailbreak Apps. If the App has not been decrypted, it will crash after installing on iDevices.

2. This resign tool will remove files at ```Watch``` and ```Plugins``` directories,so that it can make sure verify application codesign success when install.

## Getting Started
1. Open ```./Products``` and double click **EasyResigny**, or build project at ```./EasyResigny``` directory.

2. Drag, input or select the options needed.__Certifacate__,__Provision Profile__ and __App IPA__ is required.

## Install IPA
You can use [ideviceinstaller](https://github.com/libimobiledevice/ideviceinstaller) to install on your iDevices.

## Getting Help
- If it turns out that you may have found a bug, please open an issue

## Thanks To
- [maciekish / iReSign](https://github.com/maciekish/iReSign): The basic process was gleaned from the source code of this project.
- [DanTheMan827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer):This is an app for OS X that can (re)sign apps and bundle them into ipa files that are ready to be installed on an iOS device.

## License
MIT

## My Words
EasyResigny is my first Mac App tool, it is inspired by [maciekish / iReSign](https://github.com/maciekish/iReSign) and [DanTheMan827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer).Though it's not good enough,I will try my best to make it better. And what's more, welcome to open an issue to make the tool become better.