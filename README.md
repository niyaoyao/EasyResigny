# EasyResigny
![](./EasyResigny256.png)

## About
**EasyResigny** is a Mac tool for user to resign iOS App.

## Note
- To use **EasyResigny** to resign iOS App, you must ensure your App has been decrypted.You can use [dumpdecrypted](https://github.com/stefanesser/dumpdecrypted) to decrypt your app or download jailbreak Apps. If the App has not been decrypted, it will crash after installing on iDevices.

- This resign tool will remove files at ```Watch``` and ```Plugins``` directories at present,so that it can make sure verify application codesign success when install.

- **EasyResigny** cannot codesign the injected dylib, so you'd better codesign it by yourself first.(I will fix it soon.)

## Getting Started
- Open ```./Products``` and double click **EasyResigny**, or build project at ```./EasyResigny``` directory.

- Drag, input or select the options needed.__Certifacate__,__Provision Profile__ and __App IPA__ is required.

- Click ```Start EasyResigny``` button.

## Install IPA
You can use [ideviceinstaller](https://github.com/libimobiledevice/ideviceinstaller) to install on your iDevices.

## Getting Help
- If it turns out that you may have found a bug, please open an issue.
- Send email to nycode.jn@gmail.com .

## To to List
What should I do next?
### Required
- Export Command Line Logs.
- Scan Mach-O, check Mach-O decrypted or not.And if it doesn't be decrypted, show error message.
- Import hook dylib file and codesign dylib.

### Option
- Codesign Mac App.
- iDevice install IPA automation.

## Thanks To
- [maciekish / iReSign](https://github.com/maciekish/iReSign): The basic process was gleaned from the source code of this project.
- [DanTheMan827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer):This is an app for OS X that can (re)sign apps and bundle them into ipa files that are ready to be installed on an iOS device.

## License
MIT

## My Sincere Words
EasyResigny is my first Mac App tool, it is inspired by [maciekish / iReSign](https://github.com/maciekish/iReSign) and [DanTheMan827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer).Though it's not good enough,I will try my best to make it better. And what's more, welcome to open an issue to make the tool become better.Thanks a lot!

======
## 关于
**EasyResigny** 是一款使用简单的重签名 Mac 工具。

## 注意
- 在使用 **EasyResigny** 重签名之前，请先确保重签名的 App 已经被破解。你可以使用 [dumpdecrypted](https://github.com/stefanesser/dumpdecrypted) 工具进行动态解密，或者直接在越狱渠道下载 App IPA 包文件。
- 这个重签名工具目前默认会将 ```Watch``` 以及 ```Plugins``` 目录下的文件删除，以确保应用重签名生成的 IPA 文件可以正常安装到苹果设备上。
- **EasyResigny** 目前并不能将注入的 dylib 文件重签名，所以你需要自己先重签名。（我会尽快修复这个 bug 🙈	～）

## 使用
- 打开 ```./Products``` 目录，双击 **EasyResigny** 应用, 或者用 Xcode 编译 ```./EasyResigny``` 目录下的工程文件。
- 将所需要的选项补充完毕。其中 __Certifacate__,__Provision Profile__ 以及 __App IPA__ 是必填项。
- 双击 ```Start EasyResigny``` 开始重签名。

## 安装 IPA
推荐使用 [ideviceinstaller](https://github.com/libimobiledevice/ideviceinstaller) 工具来将重签名后的应用 IPA 安装到设备上。

## 获取帮助
- 发现问题，欢迎提 issue 。
- 发送邮件到 nycode.jn@gmail.com

## To Do 清单
后面需要做的任务
### 必做
- 导出命令行功能。
- 扫描二进制文件，若 Mach-O 未解密则报错提示。
- 导入需注入的 dylib 文件，并对其进行签名。

### 可选
- 签名 Mac App。
- 自动安装 IPA 到设备。（研究 IPA 安装原理）

## 致谢
- [maciekish / iReSign](https://github.com/maciekish/iReSign)
- [DanTheMan827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)

## 证书
MIT

## 作者的话
**EasyResigny** 是我第一款 Mac App 工具，是受 [maciekish / iReSign](https://github.com/maciekish/iReSign) 以及 [DanTheMan827/ios-app-signer](https://github.com/DanTheMan827/ios-app-signer) 两个产品的启发做的。目前，它还有很多 bug ，但我会尽力完善它～另外，欢迎提 issue 让它变得更好～多谢！！