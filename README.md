# File Manager(Flutter)

之前的文件管理器代码过于杂乱，20204.10.18 重构了文件管理器

之前有 file_manager_view file_manager file_selector_meng

file_manager 之前还想做一个完整的文件管理器，最后对其的设计超出我能实现的范围

现在从头开始

## Looking for maintainers

## Getting Started

```dart
FMController controller = FMController();
controller.setPort(appChannel!.port!, isRemote: true);
Get.put<FMController>(controller);

// then use widget
const FileManagerPage();
```
这部分后面会优化

## Structure

同我的诸多项目一样

对 FileManager 来说，只有 BaseUrl 不同

不区分自己是运行在 Windows/Linux/macOS/Android/iOS 甚至是 Web

只要能够给它一个 BaseUrl，它就能够工作

## Server

目前它的 Server 可以由两部分实现

### 1.Dart
一部分是 [](lib/server/file_server.dart)

由 dart 实现

这部分应用于速享的场景中，多台设备启动速享后，可以相互直接像浏览本地文件一样浏览对方的文件

### 2.Java(app_process)

一部分是 java

![](https://github.com/nightmare-space/applib/blob/main/src/main/java/com/nightmare/applib/handler/FileHandler.java)

这部分的场景是，无需对方的设备安装任何软件，只需要打开 USB 即可访问对方的文件

