import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_manager/utils/ext_util.dart';
import 'package:file_manager/view/app/app.dart';
import 'package:file_manager/view/chewie/play.dart';
import 'package:file_manager/view/flick_video_player/landscape_player/landscape_player.dart';
import 'package:file_manager/view/media-kit/media-kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';
import 'file_manager_api.dart';

class FileEntity {
  String name;
  String path;
  FileEntity? parent;
  int fileCount = 0;
  int size = 0;
  String time = '';
  String permission = '';
  FileEntity(this.name, this.path, {this.parent});

  @override
  String toString() {
    return 'FileEntity{name: $name, path: $path, parent: $parent, fileCount: $fileCount, size: $size, time: $time, permission: $permission}';
  }
}

class DirEntity extends FileEntity {
  DirEntity(super.name, super.path, {super.parent});
}

extension EntityExt on FileEntity {
  int compareTo(FileEntity other) {
    if (this is! DirEntity && other is DirEntity) {
      return 1;
    }
    if (this is DirEntity && other is! DirEntity) {
      return -1;
    }
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }
}

final RegExp _englishRegExp = RegExp(r'^[a-zA-Z]+$');
int compareEntities(FileEntity a, FileEntity b) {
  bool isPureEnglish(String str) {
    return _englishRegExp.hasMatch(str);
  }

  if (a is DirEntity && b is! DirEntity) {
    return -1;
  } else if (a is! DirEntity && b is DirEntity) {
    return 1;
  } else {
    if (isPureEnglish(a.name) && isPureEnglish(b.name)) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
    return PinyinHelper.getPinyinE(a.name).compareTo(PinyinHelper.getPinyinE(b.name));
    // return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}

// 这个用来标记当前的文件管理器模式
// 1.local 此时数据可直接从本地加载，例如图片预览，以及文件的打开
// 2.remote 此时数据需要从远程加载，图片预览是加载的远程图片。文件预览需要先下载
enum FMType {
  local,
  remote,
}

class FMController extends GetxController {
  List<FileEntity> files = [];
  List<FileEntity> selectFiles = [];
  // 这个玩意的逻辑还需要优化
  List<DirEntity> historys = [];
  String currentPath = '';
  String sdcardPath = '';
  late FileManagerAPI api;
  FMType type = FMType.local;

  void setBaseUrl(String url, {bool isRemote = false}) {
    api = FileManagerAPI(url);
    if (isRemote) {
      type = FMType.remote;
    }
  }

  void setPort(int port, {bool isRemote = false}) {
    setBaseUrl('http://localhost:$port/file');
  }

  Future<void> enterHomeDir() async {
    try {
      String path = await api.getHomePath();
      Log.e('path $path');
      await enterDir(path);
    } catch (e) {
      Log.e('enterHomeDir error $e');
    }
  }

  bool isDriveLetterPathRoot(String path) {
    RegExp regExp = RegExp(r'^[A-Za-z]://\.\.');
    return regExp.hasMatch(path);
  }

  Future<void> enterDir(String path) async {
    Log.i('enterDir raw path -> $path');
    final regex = RegExp(r'^//([A-Z]):$');
    final match = regex.firstMatch(path);
    if (match != null) {
      // enterDir raw path -> //C:
      // need to replace to C:/
      path = '${match.group(1)}:';
    }
    if (isDriveLetterPathRoot(path)) {
      Log.i('path -> $path is windows driver root replace to /');
      path = '/';
    }
    currentPath = path;
    files.clear();
    if (currentPath.endsWith('..')) {
      Log.i('currentPath enter-> $currentPath');
      // /Users/nightmare/Downloads/.. -> /Users/nightmare/Downloads
      currentPath = currentPath.substring(0, currentPath.length - 3);
      List<String> split = currentPath.split(RegExp(r'/|\\'));
      split.removeLast();
      currentPath = split.join('/');
      if (currentPath.isEmpty) {
        currentPath = '/';
      }
      Log.i('currentPath new->$currentPath<-');
    }
    Log.i('enterDir request path -> $currentPath');
    List infos = await api.getDirInfos(currentPath);
    // Log.i('infos $infos');
    DirEntity parent = DirEntity('..', currentPath);
    for (List fileInfo in infos) {
      String path = fileInfo[0];
      String permission = fileInfo[1];
      int size = fileInfo[2];
      String time = fileInfo[3];
      String type = fileInfo[4];
      String name = path.split(RegExp(r'/|\\')).last;
      if (type == 'directory') {
        DirEntity dirEntity = DirEntity(name, path);
        dirEntity.permission = permission;
        dirEntity.size = size;
        dirEntity.time = time;
        // dirEntity.fileCount = int.parse(links);
        dirEntity.time = time;
        dirEntity.parent = parent;
        files.add(dirEntity);
      }
      if (type == 'file') {
        FileEntity fileEntity = FileEntity(name, path);
        fileEntity.permission = permission;
        fileEntity.size = size;
        fileEntity.time = time;
        fileEntity.parent = parent;
        files.add(fileEntity);
      }
    }
    files.sort(compareEntities);
    files.insert(0, DirEntity('..', ''));
    update();
    //
    // for (var item in data) {
    //   Log.i(item);
    //   // TODO 测试多个安卓平台的兼容性
    //   final regex = RegExp(r'^([d\-rwx]{10})\s+(\d+)\s+(\d+)\s+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})\s+(.+)$');
    //   final match = regex.firstMatch(item);
    //   if (match != null) {
    //     // drwxrwx---  2       3452 2024-06-29 19:15 -1983762891
    //     String permission = match.group(1)!;
    //     String links = match.group(2)!;
    //     String size = match.group(3)!;
    //     String date = match.group(4)!;
    //     String time = match.group(5)!;
    //     String name = match.group(6)!;
    //     if (item.startsWith('d')) {
    //     } else {
    //       FileEntity fileEntity = FileEntity(name, item);
    //       fileEntity.permission = permission;
    //       fileEntity.size = int.parse(size);
    //       fileEntity.time = date;
    //       fileEntity.fileCount = int.parse(links);
    //       fileEntity.time = date;
    //       fileEntity.parent = parent;
    //       files.add(fileEntity);
    //     }
    //   }
    // }
  }

  void enterParentDir() {
    enterDir('$currentPath/..');
  }

  Future<void> openFile(FileEntity file) async {
    String filePath = '$currentPath/${file.name}';
    if (file.name.isImg) {
      Widget widget = PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {},
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: InteractiveViewer(
            maxScale: 5,
            child: Image.network(api.getFileUrl(filePath)),
          ),
        ),
      );
      Get.to(widget);
      return;
    }
    if (file.name.isVideo) {
      Uri uri = Uri.parse(api.getFileUrl(filePath));
      Log.i('open video -> $uri');

      Get.to(LandscapePlayer(
        url: uri.toString(),
      ));
      // Get.to(PlayWidget(
      //   url: uri.toString(),
      // ));

      // Get.to(ChewieDemo(
      //   url: uri.toString(),
      // ));
      // open with url launcher
      // await launchUrl(uri);
      return;
    }
    // final extension = path.extension(filePath);
    await OpenFile.open(filePath);
  }

  void selectFile(FileEntity file) {
    if (selectFiles.contains(file)) {
      selectFiles.remove(file);
    } else {
      selectFiles.add(file);
    }
    update();
  }
}
