import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_manager/utils/ext_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../config/config.dart';

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

class FMController extends GetxController {
  List<FileEntity> files = [];
  List<FileEntity> selectFiles = [];
  // 这个玩意的逻辑还需要优化
  List<DirEntity> historys = [];
  String currentPath = '';
  String sdcardPath = '';
  init() async {
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    Directory? directory = await getExternalStorageDirectory();
    Log.i('directory ${directory!.path}');
    String replace = '/Android/data/com.nightmare.file_manager/files';
    sdcardPath = directory.path.replaceAll(replace, '');
    enterDir(sdcardPath);
  }

  void enterDir(String path) async {
    currentPath = path;
    files.clear();
    if (currentPath.endsWith('..')) {
      currentPath = currentPath.substring(0, currentPath.length - 3);
      List<String> split = currentPath.split('/');
      split.removeLast();
      currentPath = split.join('/');
    }

    Dio dio = Dio();
    Response response = await dio.get('http://localhost:${Config.port}/getdir', queryParameters: {
      'path': currentPath,
    });
    List data = response.data;
    DirEntity parent = DirEntity('..', currentPath);
    for (var item in data) {
      Log.i(item);
      // TODO 测试多个安卓平台的兼容性
      final regex = RegExp(r'^([d\-rwx]{10})\s+(\d+)\s+(\d+)\s+(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2})\s+(.+)$');
      final match = regex.firstMatch(item);
      if (match != null) {
        // drwxrwx---  2       3452 2024-06-29 19:15 -1983762891
        String permission = match.group(1)!;
        String links = match.group(2)!;
        String size = match.group(3)!;
        String date = match.group(4)!;
        String time = match.group(5)!;
        String name = match.group(6)!;
        if (item.startsWith('d')) {
          DirEntity dirEntity = DirEntity(name, item);
          dirEntity.permission = permission;
          dirEntity.size = int.parse(size);
          dirEntity.time = time;
          dirEntity.fileCount = int.parse(links);
          dirEntity.time = date;
          dirEntity.parent = parent;
          files.add(dirEntity);
        } else {
          FileEntity fileEntity = FileEntity(name, item);
          fileEntity.permission = permission;
          fileEntity.size = int.parse(size);
          fileEntity.time = date;
          fileEntity.fileCount = int.parse(links);
          fileEntity.time = date;
          fileEntity.parent = parent;
          files.add(fileEntity);
        }
      }
    }
    files.sort(compareEntities);
    files.insert(0, DirEntity('..', ''));
    update();
  }

  void enterParentDir() {
    enterDir('$currentPath/..');
  }

  Future<void> openFile(FileEntity file) async {
    String filePath = '$currentPath/${file.name}';
    if (file.name.isImg) {
      Widget widget = InteractiveViewer(
        maxScale: 5,
        child: Image.file(
          File(filePath),
        ),
      );
      Get.to(widget);
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
